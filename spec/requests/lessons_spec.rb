require 'rails_helper'

RSpec.describe "Lessons", type: :request do
  let(:student)    { create(:user, role: :student, tickets_count: 1) }
  let(:instructor) { create(:user, role: :instructor, can_instruct_thai: true) }
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

  describe "GET /:language/instructors/:instructor_id/calendar" do
    context "未ログインの場合" do
      before { get instructor_calendar_lessons_path(language: :thai, instructor_id: instructor.id), params: { time_zone: } }
      include_examples "認証が必要"
    end

    context "ログイン済みの場合" do
      before { sign_in student }

      it "200を返す" do
        get instructor_calendar_lessons_path(language: :thai, instructor_id: instructor.id), params: { time_zone: }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /:language/instructors/:instructor_id/slots" do
    context "未ログインの場合" do
      before { get instructor_slots_lessons_path(language: :thai, instructor_id: instructor.id), params: { date: starts_at.iso8601, time_zone: } }
      include_examples "認証が必要"
    end

    context "ログイン済みの場合" do
      before { sign_in student }

      it "200を返す" do
        get instructor_slots_lessons_path(language: :thai, instructor_id: instructor.id), params: { date: starts_at.iso8601, time_zone: }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /:language/instructors/:instructor_id/new" do
    context "未ログインの場合" do
      before { get instructor_new_lesson_path(language: :thai, instructor_id: instructor.id), params: { starts_at: starts_at.iso8601 } }
      include_examples "認証が必要"
    end

    context "ログイン済みの場合" do
      before { sign_in student }

      it "200を返す" do
        get instructor_new_lesson_path(language: :thai, instructor_id: instructor.id), params: { starts_at: starts_at.iso8601 }, as: :turbo_stream
        expect(response).to have_http_status(:ok)
      end

      context "講師がすでに予約済みの場合でも" do
        before { create(:lesson, instructor:, starts_at:) }

        it "200を返す" do
          get instructor_new_lesson_path(language: :thai, instructor_id: instructor.id), params: { starts_at: starts_at.iso8601 }, as: :turbo_stream
          expect(response).to have_http_status(:ok)
        end
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

        it "ProcessLessonBookingJobをエンキューする" do
          expect {
            post lessons_path(language: :thai), params: lesson_params,
              headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.to have_enqueued_job(ProcessLessonBookingJob)
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

      context "同じ日時に別の講師とのレッスンをすでに予約している場合" do
        let(:instructor2) { create(:user, role: :instructor, can_instruct_thai: true) }
        before { create(:lesson, student:, instructor: instructor2, starts_at:) }

        let(:lesson_params) { { lesson: { starts_at: starts_at.iso8601, instructor_id: instructor.id } } }

        it "422を返す" do
          post lessons_path(language: :thai), params: lesson_params,
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "レッスンを作成しない" do
          expect {
            post lessons_path(language: :thai), params: lesson_params,
              headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.not_to change(Lesson, :count)
        end

        it "チケット枚数を変更しない" do
          expect {
            post lessons_path(language: :thai), params: lesson_params,
              headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.not_to change { student.reload.tickets_count }
        end
      end
    end
  end

  describe "GET /:language/students/:student_id/lessons" do
    context "未ログインの場合" do
      before { get student_lessons_path(language: :thai, student_id: student.id) }
      include_examples "認証が必要"
    end

    context "ログイン済みの場合" do
      before { sign_in student }

      it "200を返す" do
        get student_lessons_path(language: :thai, student_id: student.id)
        expect(response).to have_http_status(:ok)
      end

      context "予約済みのレッスンがある場合" do
        before { create(:lesson, student:, instructor:, starts_at:) }

        it "講師名が含まれる" do
          get student_lessons_path(language: :thai, student_id: student.id), params: { time_zone: }
          expect(response.body).to include(instructor.name)
        end

        it "レッスン日時が含まれる" do
          get student_lessons_path(language: :thai, student_id: student.id), params: { time_zone: }
          expect(response.body).to include(I18n.l(starts_at.in_time_zone(time_zone), format: :lesson_slot_long))
        end
      end

      context "予約済みのレッスンがない場合" do
        it "レッスン一覧が空である" do
          get student_lessons_path(language: :thai, student_id: student.id)
          expect(response.body).not_to include("btn btn-outline-primary")
        end
      end
    end
  end
end
