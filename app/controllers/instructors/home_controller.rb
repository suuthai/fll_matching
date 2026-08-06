class Instructors::HomeController < Instructors::BaseController
  include LessonsHelper
  helper LessonsHelper

  def index
  end

  def edit
    time_in_system_time_zone = Time.current

    @lesson_slots_by_language_and_hour = current_user.lesson_slots
      .each { |slot|
        slot.hour = time_in_system_time_zone.change(hour: slot.hour)
          .in_time_zone(time_zone).hour
      }
      .group_by { _1.hour }
      .transform_values { |slots|
        slots.map { |slot| [ slot.language, slot ] }.to_h
      }
  end

  def update
    attributes = params.expect(user: [
      :name,
      :profile_text,
      :face_photo,
      *User::LANGUAGES.map { |language| :"can_instruct_#{language}" },
      { lesson_slots_attributes: [ [ :id, :hour, :language, :_destroy ] ] }
    ])

    time_in_this_time_zone = Time.current.in_time_zone(time_zone)
    
    attributes[:lesson_slots_attributes]&.each_value do |slot_attributes|
      slot_attributes[:hour] = time_in_this_time_zone
        .change(hour: slot_attributes[:hour].to_i)
        .in_time_zone(Time.zone)
        .hour
    end

    current_user.update(attributes)
    render status: current_user.errors.empty? ? :ok : :unprocessable_content
  end
  
end
