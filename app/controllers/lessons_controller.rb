class LessonsController < ApplicationController
  before_action :authenticate_user!

  def calendar
    start_time = params[:start_date]&.in_time_zone(time_zone) || current_time

    @bookings_of_each_day = bookings_of_each :day,
      start_time.beginning_of_month,
      start_time.next_month.beginning_of_month,
      instructors_count * slot_hours.size

    @unavailable_before_day = start_time.month != current_time.month ? 0 :
      slot_hours.last <= current_time.hour ? current_time.day + 1 :
      current_time.day

    @language = language
    @time_zone = time_zone
  end

  def slots
    time_of_this_date = params[:date].in_time_zone(time_zone)

    bookings_of_each_slot = bookings_of_each :hour,
      time_of_this_date.beginning_of_day,
      time_of_this_date.tomorrow.beginning_of_day,
      instructors_count

    @slots = slot_hours.map { |hour|
      {
        time: time_of_this_date.change(hour:),
        **(bookings_of_each_slot[hour] || {})
      }
    }

    if time_of_this_date.day == current_time.day
      @slots.each { |slot|
        slot[:unavailable] = slot[:time].hour <= current_time.hour
      }
    end

    @language = language
  end

  def new
    # Railsサーバーに設定されたタイムゾーンではなく、
    # starts_atパラメーター中に含まれるタイムゾーンでTimeインスタンスを得たいので、
    # Time.zone.parseではなく意図的にTime.parseを使っている。
    @starts_at = Time.parse params[:starts_at]

    @lesson = Lesson.new starts_at: @starts_at
    @language = language
  end

  def create
    return render_error :no_ticket if current_user.tickets_count <= 0

    lesson = Lesson.new({
      student: current_user,
      **params.require(:lesson).permit(:starts_at)
    })

    begin
      ActiveRecord::Base.transaction do
        unavailable_instructor_ids = Lesson.select(:instructor_id)
          .where(starts_at: lesson.starts_at)

        available_instructors = User.select(:id)
          .where(instructional_language: language)
          .where.not(id: unavailable_instructor_ids)

        raise NoAvailableInstructor if available_instructors.size <= 0

        lesson.instructor = available_instructors.sample
        lesson.save!
        current_user.decrement!(:tickets_count)
      end
    rescue NoAvailableInstructor
      render_error :fully_booked
    rescue
      render_error :an_error_occurred
    end
  end

  private

  NoAvailableInstructor = Class.new(StandardError)

  def time_zone
    @time_zone ||= params[:time_zone] || Time.zone.name
  end

  def current_time
    @current_time ||= Time.current.in_time_zone(time_zone)
  end

  def instructors_count
    @instructors_count ||= User.where(instructional_language: language).count
  end

  def slot_hours
    return @slot_hours if @slot_hours

    slot_hours_in_jst = 7..22
    time_in_jst = Time.current.in_time_zone("Asia/Tokyo")

    @slot_hours = slot_hours_in_jst.map { |hour|
      time_in_jst.change(hour:).in_time_zone(time_zone).hour
    }.sort
  end

  def bookings_of_each(date_method_name, from, to, max_lessons_count)
    Lesson
      .joins(:instructor)
      .where(users: { instructional_language: language })
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
