require 'rails_helper'

RSpec.describe "Home", type: :request do
  let(:student)              { create(:user) }
  let(:thai_instructor)      { create(:user, role: :instructor, can_instruct_thai: true) }
  let(:lao_instructor)       { create(:user, role: :instructor, can_instruct_lao: true) }
  let(:thai_lesson_slot)     { create(:lesson_slot, instructor: thai_instructor, language: :thai, hour: 10) }
  let(:lao_lesson_slot)      { create(:lesson_slot, instructor: lao_instructor, language: :lao, hour: 10) }

  describe "GET /:language" do
    context "未ログインの場合" do
      before { get language_root_path(:thai) }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みの場合" do
      before do
        thai_lesson_slot
        lao_lesson_slot
        sign_in student
      end

      it "200を返す" do
        get language_root_path(:thai)
        expect(response).to have_http_status(:ok)
      end

      it "指定した言語を指導可能な講師のみ表示する" do
        get language_root_path(:thai)
        expect(response.body).to include(thai_instructor.name)
        expect(response.body).not_to include(lao_instructor.name)
      end
    end
  end
end
