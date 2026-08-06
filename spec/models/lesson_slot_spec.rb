require 'rails_helper'

RSpec.describe LessonSlot, type: :model do
  describe "アソシエーション" do
    it "instructorはUserに属する" do
      lesson_slot = create(:lesson_slot)
      expect(lesson_slot.instructor).to be_a(User)
    end
  end

  describe "language" do
    it "User::LANGUAGESと同じ並び・値のenumになっている" do
      expect(LessonSlot.languages).to eq(
        User::LANGUAGES.each_with_index.to_h { |language, value| [ language.to_s, value ] }
      )
    end
  end

  describe "ユニーク制約" do
    it "同じ講師が同じhour・languageの組み合わせを2つ持てない" do
      instructor = create(:user, role: :instructor)
      create(:lesson_slot, instructor:, hour: 10, language: :thai)

      expect {
        create(:lesson_slot, instructor:, hour: 10, language: :thai)
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "同じ講師でもhourかlanguageが異なれば作成できる" do
      instructor = create(:user, role: :instructor)
      create(:lesson_slot, instructor:, hour: 10, language: :thai)

      expect {
        create(:lesson_slot, instructor:, hour: 11, language: :thai)
      }.not_to raise_error
    end
  end
end
