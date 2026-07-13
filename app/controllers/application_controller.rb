class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def language
    params[:language]
  end

  def after_sign_in_path_for(resource)
    return admin_root_path if resource.admin?
    return instructors_home_path if resource.instructor?
    super
  end
end
