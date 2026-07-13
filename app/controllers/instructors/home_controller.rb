class Instructors::HomeController < Instructors::BaseController
  def index
  end

  def edit
  end

  def update
    current_user.update(params.require(:user).permit(
      :name,
      :profile_text,
      :face_photo,
      *User::LANGUAGES.map { |language| :"can_instruct_#{language}" }
    ))

    render status: current_user.errors.empty? ? :ok : :unprocessable_content
  end
end
