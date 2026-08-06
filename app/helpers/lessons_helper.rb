module LessonsHelper
  def time_zone
    @time_zone ||= params[:time_zone] || Time.zone.name
  end

  def slot_hours
    return @slot_hours if @slot_hours

    slot_hours_in_jst = 7..22
    time_in_jst = Time.current.in_time_zone("Asia/Tokyo")

    @slot_hours = slot_hours_in_jst.map { |hour|
      time_in_jst.change(hour:).in_time_zone(time_zone).hour
    }.sort
  end
end
