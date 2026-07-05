class LessonMailer < ApplicationMailer
  def student_confirmation(lesson)
    @lesson = lesson
    mail(to: lesson.student.email, subject: "レッスンが予約されました")
  end

  def instructor_notification(lesson)
    @lesson = lesson
    mail(to: lesson.instructor.email, subject: "New lesson booked")
  end
end
