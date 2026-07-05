class Admin::HomeController < Admin::BaseController
  def index
    @users_count       = User.count
    @lessons_count     = Lesson.count
    @students_count    = User.student.count
    @instructors_count = User.instructor.count
  end
end
