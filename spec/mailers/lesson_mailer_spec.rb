require 'rails_helper'

RSpec.describe LessonMailer, type: :mailer do
  let(:zoom_url) { "https://zoom.us/j/123456789?pwd=abcdef" }
  let(:lesson) { create(:lesson, zoom_url:) }

  describe "#student_confirmation" do
    let(:mail) { described_class.student_confirmation(lesson) }

    it "生徒のメールアドレスに送信する" do
      expect(mail.to).to contain_exactly(lesson.student.email)
    end

    it "件名が正しい" do
      expect(mail.subject).to eq("レッスンが予約されました")
    end

    it "講師名が含まれる" do
      expect(mail.body.encoded).to include(lesson.instructor.name)
    end

    it "Zoom URLが含まれる" do
      expect(mail.body.encoded).to include(zoom_url)
    end
  end

  describe "#instructor_notification" do
    let(:mail) { described_class.instructor_notification(lesson) }

    it "講師のメールアドレスに送信する" do
      expect(mail.to).to contain_exactly(lesson.instructor.email)
    end

    it "件名が正しい" do
      expect(mail.subject).to eq("New lesson booked")
    end

    it "生徒名が含まれる" do
      expect(mail.body.encoded).to include(lesson.student.name)
    end

    it "Zoom URLが含まれる" do
      expect(mail.body.encoded).to include(zoom_url)
    end
  end
end