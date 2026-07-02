class ProcessLessonBookingJob < ApplicationJob
  queue_as :default
  retry_on ZoomClient::ApiError, wait: :polynomially_longer, attempts: 5

  def perform(lesson_id)
    lesson = Lesson.includes(:student, :instructor).find(lesson_id)
    zoom_url = ZoomClient.new.create_meeting(
      topic: "#{lesson.instructor.name} × #{lesson.student.name}",
      start_time: lesson.starts_at
    )
    lesson.update!(zoom_url:)
    LessonMailer.student_confirmation(lesson).deliver_later
    LessonMailer.instructor_notification(lesson).deliver_later
  end
end