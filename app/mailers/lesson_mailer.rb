class LessonMailer < ApplicationMailer
  def student_confirmation(lesson, language)
    @lesson = lesson
    @language = language
    mail(to: lesson.student.email, subject: "レッスンが予約されました")
  end

  def instructor_notification(lesson, language)
    @lesson = lesson
    @language = language
    mail(to: lesson.instructor.email, subject: "New lesson booked")
  end
end
