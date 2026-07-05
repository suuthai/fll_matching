require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "name, email, password がある場合は有効" do
      expect(build(:user)).to be_valid
    end

    it "name がない場合は無効" do
      expect(build(:user, name: nil)).to be_invalid
    end
  end

  describe "#recent_instructor" do
    let(:student)     { create(:user, role: :student) }
    let(:instructor1) { create(:user, role: :instructor) }
    let(:instructor2) { create(:user, role: :instructor) }

    it "レッスンがない場合はnilを返す" do
      expect(student.recent_instructor).to be_nil
    end

    it "作成日時が最も新しいレッスンの講師を返す" do
      create(:lesson, student:, instructor: instructor1, starts_at: 2.days.from_now.beginning_of_hour)
      create(:lesson, student:, instructor: instructor2, starts_at: 3.days.from_now.beginning_of_hour)
      expect(student.recent_instructor).to eq(instructor2)
    end
  end
end
