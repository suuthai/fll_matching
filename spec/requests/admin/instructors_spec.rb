require 'rails_helper'

RSpec.describe "Admin::Instructors", type: :request do
  let(:admin)       { create(:user, :admin) }
  let(:student)     { create(:user) }
  let!(:instructor) { create(:user, role: :instructor, can_instruct_thai: true, can_instruct_lao: true) }

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

      it "指導可能な言語のクラスが付与されたtd要素を表示する" do
        td = Nokogiri::HTML(response.body).at_css("td.language-thai.language-lao")
        expect(td).not_to be_nil
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
          can_instruct_thai: true,
          can_instruct_lao: true,
          password: "password123"
        }
      }
    end

    let(:invalid_params) do
      {
        user: {
          name: "",
          email: "",
          can_instruct_thai: true,
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

        it "指定した言語を指導可能として設定する" do
          post admin_instructors_path, params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          created_instructor = User.instructor.order(:id).last
          expect(created_instructor.instructable_languages).to contain_exactly(:thai, :lao)
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

  describe "GET /admin/instructors/:id/edit" do
    context "未ログインの場合" do
      before { get edit_admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" } }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者以外がログインしている場合" do
      before do
        sign_in student
        get edit_admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者がログインしている場合" do
      before do
        sign_in admin
        get edit_admin_instructor_path(instructor), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "200を返す" do
        expect(response).to have_http_status(:ok)
      end

      it "編集フォームに現在の講師名を表示する" do
        expect(response.body).to include(instructor.name)
      end
    end
  end

  describe "PATCH /admin/instructors/:id" do
    let(:valid_params) do
      { user: { name: "更新後の名前", email: instructor.email, can_instruct_thai: true, can_instruct_lao: false, can_instruct_khmer: true } }
    end

    let(:invalid_params) do
      { user: { name: "", email: instructor.email, can_instruct_thai: true } }
    end

    context "未ログインの場合" do
      before { patch admin_instructor_path(instructor), params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" } }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "講師情報を更新しない" do
        expect(instructor.reload.name).not_to eq("更新後の名前")
      end
    end

    context "管理者以外がログインしている場合" do
      before { sign_in student }

      it "サインインページにリダイレクトする" do
        patch admin_instructor_path(instructor), params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "講師情報を更新しない" do
        patch admin_instructor_path(instructor), params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(instructor.reload.name).not_to eq("更新後の名前")
      end
    end

    context "管理者がログインしている場合" do
      before { sign_in admin }

      context "有効なパラメータの場合" do
        it "講師情報を更新する" do
          patch admin_instructor_path(instructor), params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.name).to eq("更新後の名前")
        end

        it "200を返す" do
          patch admin_instructor_path(instructor), params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:ok)
        end

        it "指定した言語を指導可能として更新する" do
          patch admin_instructor_path(instructor), params: valid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.instructable_languages).to contain_exactly(:thai, :khmer)
        end
      end

      context "無効なパラメータの場合" do
        it "講師情報を更新しない" do
          patch admin_instructor_path(instructor), params: invalid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.name).not_to eq("")
        end

        it "422を返す" do
          patch admin_instructor_path(instructor), params: invalid_params, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "パスワードを空欄で送信した場合" do
        let(:params_with_blank_password) do
          { user: { name: "更新後の名前", email: instructor.email, can_instruct_thai: true, password: "" } }
        end

        it "既存のパスワードを維持する" do
          encrypted_password_was = instructor.encrypted_password
          patch admin_instructor_path(instructor), params: params_with_blank_password,
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.encrypted_password).to eq(encrypted_password_was)
        end

        it "パスワード以外の属性は更新する" do
          patch admin_instructor_path(instructor), params: params_with_blank_password,
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.name).to eq("更新後の名前")
        end

        it "200を返す" do
          patch admin_instructor_path(instructor), params: params_with_blank_password,
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:ok)
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
