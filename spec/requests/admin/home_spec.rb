require 'rails_helper'

RSpec.describe "Admin::Home", type: :request do
  let(:admin)   { create(:user, :admin) }
  let(:student) { create(:user) }

  describe "GET /admin" do
    context "未ログインの場合" do
      before { get admin_root_path }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者以外がログインしている場合" do
      before do
        sign_in student
        get admin_root_path
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "管理者がログインしている場合" do
      before do
        sign_in admin
        get admin_root_path
      end

      it "200を返す" do
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "管理者のログイン後リダイレクト" do
    it "管理者でログインすると /admin にリダイレクトする" do
      post user_session_path, params: { user: { email: admin.email, password: "password123" } }
      expect(response).to redirect_to(admin_root_path)
    end

    it "一般ユーザーでログインしても /admin にリダイレクトしない" do
      post user_session_path, params: { user: { email: student.email, password: "password123" } }
      expect(response).not_to redirect_to(admin_root_path)
    end
  end
end
