require 'rails_helper'

RSpec.describe Lesson, type: :model do
  describe "アソシエーション" do
    it "studentはUserに属する" do
      lesson = build(:lesson)
      expect(lesson.student).to be_a(User)
    end

    it "instructorはUserに属する" do
      lesson = build(:lesson)
      expect(lesson.instructor).to be_a(User)
    end
  end

  describe "バリデーション" do
    it "student, instructor, starts_at がある場合は有効" do
      expect(build(:lesson)).to be_valid
    end

    it "student がない場合は無効" do
      expect(build(:lesson, student: nil)).to be_invalid
    end

    it "instructor がない場合は無効" do
      expect(build(:lesson, instructor: nil)).to be_invalid
    end

    it "starts_at がない場合は無効" do
      expect(build(:lesson, starts_at: nil)).to be_invalid
    end
  end

  describe "ユニーク制約" do
    let(:instructor) { create(:user, role: :instructor) }
    let(:student) { create(:user, role: :student) }
    let(:starts_at) { Time.current.beginning_of_hour + 1.day }

    it "同じ講師が同じ時間に2つ目のレッスンを持てない" do
      create(:lesson, instructor:, starts_at:)
      duplicate = build(:lesson, instructor:, starts_at:)
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "同じ生徒が同じ時間に2つ目のレッスンを持てない" do
      create(:lesson, student:, starts_at:)
      duplicate = build(:lesson, student:, starts_at:)
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end