require 'rails_helper'

RSpec.describe "Instructors::Home", type: :request do
  let(:instructor) { create(:user, role: :instructor) }
  let(:student)    { create(:user) }
  let(:admin)      { create(:user, :admin) }

  describe "GET /instructors" do
    context "未ログインの場合" do
      before { get instructors_root_path }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "講師以外がログインしている場合" do
      before do
        sign_in student
        get instructors_root_path
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "講師がログインしている場合" do
      before do
        sign_in instructor
        get instructors_root_path
      end

      it "200を返す" do
        expect(response).to have_http_status(:ok)
      end

      it "講師専用のスタイルシートを読み込む" do
        expect(response.body).to include("application-instructors")
      end

      it "通常のスタイルシートは読み込まない" do
        expect(response.body).not_to match(%r{/assets/application-[0-9a-f]+\.css})
      end

      it "ヘッダーにtext-bg-primaryクラスを付与し、bg-bodyは付与しない" do
        header = Nokogiri::HTML(response.body).at_css("header")
        expect(header["class"]).to include("text-bg-primary")
        expect(header["class"]).not_to include("bg-body")
      end
    end
  end

  describe "講師のログイン後リダイレクト" do
    it "講師でログインすると /instructors にリダイレクトする" do
      post user_session_path, params: { user: { email: instructor.email, password: "password123" } }
      expect(response).to redirect_to(instructors_root_path)
    end

    it "一般ユーザーでログインしても /instructors にリダイレクトしない" do
      post user_session_path, params: { user: { email: student.email, password: "password123" } }
      expect(response).not_to redirect_to(instructors_root_path)
    end

    it "管理者でログインしても /instructors にリダイレクトしない" do
      post user_session_path, params: { user: { email: admin.email, password: "password123" } }
      expect(response).not_to redirect_to(instructors_root_path)
    end
  end
end
