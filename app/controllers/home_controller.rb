class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @language = language
    @instructors = User.where("can_instruct_#{language}": true)
    @initially_selected_instructor_id = current_user.recent_instructor&.id
  end
end
