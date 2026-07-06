require 'rails_helper'

RSpec.describe ProcessLessonBookingJob, type: :job do
  describe "#perform" do
    let(:lesson) { create(:lesson) }
    let(:zoom_url) { "https://zoom.us/j/123456789?pwd=abcdef" }
    let(:language) { "thai" }

    before do
      allow_any_instance_of(ZoomClient).to receive(:create_meeting).and_return(zoom_url)
    end

    it "レッスンのzoom_urlを設定する" do
      described_class.perform_now(lesson.id, language)
      expect(lesson.reload.zoom_url).to eq(zoom_url)
    end

    it "正しいトピックと開始時刻でZoomミーティングを作成する" do
      expect_any_instance_of(ZoomClient).to receive(:create_meeting).with(
        topic: "#{lesson.instructor.name} × #{lesson.student.name}",
        start_time: lesson.starts_at
      ).and_return(zoom_url)

      described_class.perform_now(lesson.id, language)
    end

    it "生徒に確認メールを送信する" do
      expect {
        described_class.perform_now(lesson.id, language)
      }.to have_enqueued_mail(LessonMailer, :student_confirmation)
    end

    it "講師に通知メールを送信する" do
      expect {
        described_class.perform_now(lesson.id, language)
      }.to have_enqueued_mail(LessonMailer, :instructor_notification)
    end
  end
end
