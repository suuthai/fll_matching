class Admin::InstructorsController < Admin::BaseController
  def index
    @instructors = User.where(role: :instructor).order(id: :desc)
  end

  def new
    @instructor = User.new(role: :instructor)
  end

  def create
    @instructor = User.create({
      role: :instructor,
      **params.require(:user).permit(
        :name,
        :email,
        :instructional_language,
        :password
      )
    })

    render status: @instructor.persisted? ? :ok : :unprocessable_content
  end

  def confirm_destruction
    @instructor = User.find(params[:id])
    @booked_lessons = @instructor.lessons_as_instructor.where("starts_at >= ?", 50.minutes.ago)
  end

  def destroy
    @instructor = User.find(params[:id]).destroy
  end
end
