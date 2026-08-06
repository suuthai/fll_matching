class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @language = language

    @instructors = User.joins(:lesson_slots)
      .where("can_instruct_#{language}": true)
      .select(:id, :name)
      .distinct

    @initially_selected_instructor_id = current_user.recent_instructor&.id
  end
end
