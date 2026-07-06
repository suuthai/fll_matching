class Instructors::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_instructor!

  layout "instructors"

  private

  def require_instructor!
    redirect_to new_user_session_path, status: :see_other, alert: "講師のみアクセスできます。" unless current_user.instructor?
  end
end
