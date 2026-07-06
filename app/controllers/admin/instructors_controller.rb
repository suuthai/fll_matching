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
        :password,
        *User::LANGUAGES.map { |language| :"can_instruct_#{language}" }
      )
    })

    render status: @instructor.persisted? ? :ok : :unprocessable_content
  end

  def edit
    @instructor = User.find(params[:id])
  end

  def update
    @instructor = User.find(params[:id])

    attributes = params.require(:user).permit(
      :name,
      :email,
      :password,
      *User::LANGUAGES.map { |language| :"can_instruct_#{language}" }
    )
    attributes.delete(:password) if attributes[:password].blank?

    @instructor.update(attributes)

    render status: @instructor.errors.empty? ? :ok : :unprocessable_content
  end

  def confirm_destruction
    @instructor = User.find(params[:id])
    @booked_lessons = @instructor.lessons_as_instructor.where("starts_at >= ?", 50.minutes.ago)
  end

  def destroy
    @instructor = User.find(params[:id]).destroy
  end
end
