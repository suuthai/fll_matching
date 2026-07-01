require 'rails_helper'

RSpec.describe "Lessons", type: :request do
  let(:student)    { create(:user, role: :student, tickets_count: 1) }
  let(:instructor) { create(:user, role: :instructor, instructional_language: :thai) }
  let(:time_zone)  { "Asia/Tokyo" }
  let(:starts_at)  { Time.current.in_time_zone(time_zone).beginning_of_hour + 1.day }

  shared_examples "認証が必要" do
    it "未ログインの場合はサインインページにリダイレクトする" do
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /:language/lessons/calendar" do
    context "未ログインの場合" do
      before { get calendar_lessons_path(language: :thai), params: { time_zone: } }
      include_examples "認証が必要"
    end

    context "ログイン済みの場合" do
      before { sign_in student }

      it "200を返す" do
        get calendar_lessons_path(language: :thai), params: { time_zone: }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /:language/lessons/slots" do
    context "未ログインの場合" do
      before { get slots_lessons_path(language: :thai), params: { date: starts_at.iso8601, time_zone: } }
      include_examples "認証が必要"
    end

    context "ログイン済みの場合" do
      before { sign_in student }

      it "200を返す" do
        get slots_lessons_path(language: :thai), params: { date: starts_at.iso8601, time_zone: }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /:language/lessons/new" do
    context "未ログインの場合" do
      before { get new_lesson_path(language: :thai), params: { starts_at: starts_at.iso8601 } }
      include_examples "認証が必要"
    end

    context "ログイン済みの場合" do
      before do
        sign_in student
        instructor
      end

      it "200を返す" do
        get new_lesson_path(language: :thai), params: { starts_at: starts_at.iso8601 }, as: :turbo_stream
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /:language/lessons" do
    let(:lesson_params) { { lesson: { starts_at: starts_at.iso8601 } } }

    context "未ログインの場合" do
      before { post lessons_path(language: :thai), params: lesson_params }
      include_examples "認証が必要"
    end

    context "ログイン済みの場合" do
      before { sign_in student }

      context "チケットが0枚の場合" do
        let(:student) { create(:user, role: :student, tickets_count: 0) }

        it "422を返す" do
          post lessons_path(language: :thai), params: lesson_params, as: :turbo_stream
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "空き講師がいる場合" do
        before { instructor }

        let(:lesson_params) { { lesson: { starts_at: starts_at.iso8601, instructor_id: instructor.id } } }

        it "レッスンを作成する" do
          expect {
            post lessons_path(language: :thai), params: lesson_params,
              headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.to change(Lesson, :count).by(1)
        end

        it "チケット枚数を1減らす" do
          expect {
            post lessons_path(language: :thai), params: lesson_params,
              headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.to change { student.reload.tickets_count }.by(-1)
        end
      end

      context "空き講師がいない場合" do
        before { create(:lesson, instructor:, starts_at:) }

        it "422を返す" do
          post lessons_path(language: :thai), params: lesson_params, as: :turbo_stream
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "レッスンを作成しない" do
          expect {
            post lessons_path(language: :thai), params: lesson_params, as: :turbo_stream
          }.not_to change(Lesson, :count)
        end

        it "チケット枚数を変更しない" do
          expect {
            post lessons_path(language: :thai), params: lesson_params, as: :turbo_stream
          }.not_to change { student.reload.tickets_count }
        end
      end
    end
  end
end