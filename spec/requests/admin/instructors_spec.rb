require 'rails_helper'

RSpec.describe "Admin::Instructors", type: :request do
  let(:admin)       { create(:user, :admin) }
  let(:student)     { create(:user) }
  let!(:instructor) { create(:user, role: :instructor, instructional_language: :thai) }

  describe "GET /admin/instructors" do
    context "未ログインの場合" do
      before { get admin_instructors_path }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者以外がログインしている場合" do
      before do
        sign_in student
        get admin_instructors_path
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者がログインしている場合" do
      before do
        sign_in admin
        get admin_instructors_path
      end

      it "200を返す" do
        expect(response).to have_http_status(:ok)
      end

      it "講師一覧を表示する" do
        expect(response.body).to include(instructor.name)
      end
    end
  end

  describe "GET /admin/instructors/new" do
    context "未ログインの場合" do
      before { get new_admin_instructor_path, headers: { "Accept" => "text/vnd.turbo-stream.html" } }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者がログインしている場合" do
      before do
        sign_in admin
        get new_admin_instructor_path, headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "200を返す" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /admin/instructors" do
    let(:valid_params) do
      {
        user: {
          name: "新しい講師",
          email: "new_instructor@example.com",
          instructional_language: :thai,
          password: "password123"
        }
      }
    end

    let(:invalid_params) do
      {
        user: {
          name: "",
          email: "",
          instructional_language: :thai,
          password: ""
        }
      }
    end

    context "未ログインの場合" do
      before { post admin_instructors_path, params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" } }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者がログインしている場合" do
      before { sign_in admin }

      context "有効なパラメータの場合" do
        it "講師を作成する" do
          expect {
            post admin_instructors_path, params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.to change(User.instructor, :count).by(1)
        end

        it "200を返す" do
          post admin_instructors_path, params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:ok)
        end
      end

      context "無効なパラメータの場合" do
        it "講師を作成しない" do
          expect {
            post admin_instructors_path, params: invalid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.not_to change(User.instructor, :count)
        end

        it "422を返す" do
          post admin_instructors_path, params: invalid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end
  end

  describe "GET /admin/instructors/:id/confirm_destruction" do
    context "未ログインの場合" do
      before do
        get confirm_destruction_admin_instructor_path(instructor),
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者以外がログインしている場合" do
      before do
        sign_in student
        get confirm_destruction_admin_instructor_path(instructor),
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者がログインしている場合" do
      before do
        sign_in admin
        get confirm_destruction_admin_instructor_path(instructor),
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "200を返す" do
        expect(response).to have_http_status(:ok)
      end

      it "削除確認メッセージに講師名を表示する" do
        expect(response.body).to include(instructor.name)
      end

      it "警告を表示しない" do
        expect(response.body).not_to include("alert-danger")
      end

      context "予約されたレッスン(未来のレッスン)が残っている場合" do
        let!(:lesson) { create(:lesson, instructor: instructor, starts_at: 1.day.from_now) }

        it "警告を表示する" do
          get confirm_destruction_admin_instructor_path(instructor),
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response.body).to include("alert-danger")
        end
      end

      context "開始直後のレッスン(開始から50分未満)が残っている場合" do
        let!(:lesson) { create(:lesson, instructor: instructor, starts_at: 10.minutes.ago) }

        it "警告を表示する" do
          get confirm_destruction_admin_instructor_path(instructor),
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response.body).to include("alert-danger")
        end
      end

      context "完全に終了したレッスン(開始から50分以上)しかない場合" do
        let!(:lesson) { create(:lesson, instructor: instructor, starts_at: 51.minutes.ago) }

        it "警告を表示しない" do
          get confirm_destruction_admin_instructor_path(instructor),
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response.body).not_to include("alert-danger")
        end
      end
    end
  end

  describe "DELETE /admin/instructors/:id" do
    context "未ログインの場合" do
      before do
        delete admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "講師を削除しない" do
        expect(instructor.reload).to be_persisted
      end
    end

    context "管理者以外がログインしている場合" do
      before { sign_in student }

      it "サインインページにリダイレクトする" do
        delete admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "講師を削除しない" do
        expect {
          delete admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.not_to change(User.instructor, :count)
      end
    end

    context "管理者がログインしている場合" do
      before { sign_in admin }

      it "講師を削除する" do
        expect {
          delete admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.to change(User.instructor, :count).by(-1)
      end

      it "200を返す" do
        delete admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:ok)
      end

      context "講師にレッスンが紐づいている場合" do
        let!(:lesson) { create(:lesson, instructor: instructor) }

        it "紐づくレッスンも一緒に削除する" do
          expect {
            delete admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.to change(Lesson, :count).by(-1)
        end

        it "講師を削除する" do
          expect {
            delete admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
          }.to change(User.instructor, :count).by(-1)
        end

        it "200を返す" do
          delete admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
