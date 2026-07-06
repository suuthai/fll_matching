class LessonsController < ApplicationController
  before_action :authenticate_user!

  def calendar
    start_time = params[:start_date]&.in_time_zone(time_zone) || current_time

    @bookings_of_each_day = bookings_of_each :day,
      start_time.beginning_of_month,
      start_time.next_month.beginning_of_month,
      slot_hours.size

    @unavailable_before_day = start_time.to_date != current_time.to_date ? 0 :
      slot_hours.last <= current_time.hour ? current_time.day + 1 :
      current_time.day

    @time_zone = time_zone

    @slots_path = instructor_id ?
      instructor_slots_lessons_path(language:, instructor_id:) :
      slots_lessons_path(language:)
  end

  def slots
    time_of_this_date = params[:date].in_time_zone(time_zone)

    bookings_of_each_slot = bookings_of_each :hour,
      time_of_this_date.beginning_of_day,
      time_of_this_date.tomorrow.beginning_of_day,
      1

    @slots = slot_hours.map { |hour|
      {
        time: time_of_this_date.change(hour:),
        **(bookings_of_each_slot[hour] || {})
      }
    }

    if time_of_this_date.to_date == current_time.to_date
      @slots.each { |slot|
        slot[:unavailable] = slot[:time].hour <= current_time.hour
      }
    end

    @new_path = instructor_id ?
      instructor_new_lesson_path(language:, instructor_id:) :
      new_lesson_path(language:)
  end

  def new
    # Railsサーバーに設定されたタイムゾーンではなく、
    # starts_atパラメーター中に含まれるタイムゾーンでTimeインスタンスを得たいので、
    # Time.zone.parseではなく意図的にTime.parseを使っている。
    @starts_at = Time.parse params[:starts_at]

    @instructors, initially_selected_instructor_id = if instructor_id
      [ [ User.find(instructor_id) ], instructor_id ]
    else
      unavailable_instructor_ids = Lesson.select(:instructor_id)
        .where(starts_at: @starts_at)

      available_instructors = User
        .where("can_instruct_#{language}": true)
        .where.not(id: unavailable_instructor_ids)

      return render_error :fully_booked if available_instructors.size <= 0

      [ available_instructors, current_user.recent_instructor&.id ]
    end

    @lesson = Lesson.new starts_at: @starts_at,
      instructor: @instructors.find { _1.id == initially_selected_instructor_id } ||
        @instructors.sample

    @language = language
  end

  def create
    return render_error :no_tickets if current_user.tickets_count <= 0

    begin
      ActiveRecord::Base.transaction do
        lesson = Lesson.create!({
          student: current_user,
          **params.require(:lesson).permit(:starts_at, :instructor_id)
        })

        current_user.decrement!(:tickets_count)
        ProcessLessonBookingJob.perform_later(lesson.id, language)
      end
    rescue ActiveRecord::RecordNotUnique
      render_error :fully_booked
    rescue => error
      Rails.logger.error error
      render_error :an_error_occurred
    end
  end

  def index
    @lessons = Lesson.joins(:instructor)
      .select("lessons.starts_at, lessons.zoom_url, users.name AS instructor_name")
      .where(student_id:, users: { "can_instruct_#{language}": true })
      .where("starts_at >= ?", 1.hour.ago)
      .order(starts_at: :asc)
      .map { |lesson|
        {
          starts_at: lesson.starts_at.in_time_zone(time_zone),
          instructor_name: lesson.instructor_name,
          zoom_url: lesson.zoom_url
        }
      }
  end

  private

  def time_zone
    @time_zone ||= params[:time_zone] || Time.zone.name
  end

  def instructor_id
    params[:instructor_id]
  end

  def student_id
    params[:student_id]
  end

  def current_time
    @current_time ||= Time.current.in_time_zone(time_zone)
  end

  def instructors_count
    @instructors_count ||= User.where("can_instruct_#{language}": true).count
  end

  def slot_hours
    return @slot_hours if @slot_hours

    slot_hours_in_jst = 7..22
    time_in_jst = Time.current.in_time_zone("Asia/Tokyo")

    @slot_hours = slot_hours_in_jst.map { |hour|
      time_in_jst.change(hour:).in_time_zone(time_zone).hour
    }.sort
  end

  def bookings_of_each(date_method_name, from, to, lessons_count_coefficient)
    records = Lesson.joins(:instructor)

    records, max_lessons_count = instructor_id ?
      [
        records.where("instructor_id = ? OR student_id = ?", instructor_id, current_user.id),
        lessons_count_coefficient
      ] : [
        records.where(users: { "can_instruct_#{language}": true }),
        instructors_count * lessons_count_coefficient
      ]

    records
      .where("starts_at >= ? AND starts_at < ?", from, to)
      .group_by { |lesson| lesson.starts_at.in_time_zone(time_zone).send(date_method_name) }
      .transform_values { |lessons|
        {
          full: lessons.size >= max_lessons_count,
          booked_by_current_user: lessons.any? { |lesson| lesson.student_id == current_user.id }
        }
      }
  end

  def render_error(error)
    @error = error
    render status: :unprocessable_content
  end
end
