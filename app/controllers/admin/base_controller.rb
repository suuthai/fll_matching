class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  layout "admin"

  private

  def require_admin!
    redirect_to new_user_session_path, status: :see_other, alert: "管理者のみアクセスできます。" unless current_user.admin?
  end
end