require 'rails_helper'

RSpec.describe "Instructors::Home", type: :request do
  let(:instructor) { create(:user, role: :instructor) }
  let(:student)    { create(:user) }
  let(:admin)      { create(:user, :admin) }

  describe "GET /instructors/home" do
    context "未ログインの場合" do
      before { get instructors_home_path }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "講師以外がログインしている場合" do
      before do
        sign_in student
        get instructors_home_path
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "講師がログインしている場合" do
      before do
        sign_in instructor
        get instructors_home_path
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

      it "顔写真の編集リンクを表示する" do
        expect(response.body).to include(instructors_edit_path)
      end
    end
  end

  describe "GET /instructors/home/edit" do
    context "未ログインの場合" do
      before { get instructors_edit_path, headers: { "Accept" => "text/vnd.turbo-stream.html" } }

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "講師以外がログインしている場合" do
      before do
        sign_in student
        get instructors_edit_path, headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "講師がログインしている場合" do
      before do
        sign_in instructor
        get instructors_edit_path, headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "200を返す" do
        expect(response).to have_http_status(:ok)
      end

      it "顔写真のアップロードフォームを表示する" do
        expect(Nokogiri::HTML(response.body).at_css("input[type=file][name='user[face_photo]']")).not_to be_nil
      end

      it "顔写真が未設定の場合はrequiredにする" do
        file_field = Nokogiri::HTML(response.body).at_css("input[type=file][name='user[face_photo]']")
        expect(file_field["required"]).to eq("required")
      end

      it "顔写真が未設定の場合は1列で表示する" do
        expect(Nokogiri::HTML(response.body).css(".col-md-4, .col-md-8")).to be_empty
      end

      it "顔写真が未設定の場合はラベルを「顔写真」にする" do
        label = Nokogiri::HTML(response.body).at_css("label[for=user_face_photo]")
        expect(label.text).to eq("顔写真")
      end

      context "顔写真を設定している場合" do
        before do
          instructor.face_photo.attach(fixture_file_upload("face_photo.png", "image/png"))
          get instructors_edit_path, headers: { "Accept" => "text/vnd.turbo-stream.html" }
        end

        it "現在の顔写真を表示する" do
          expect(Nokogiri::HTML(response.body).at_css("img")).not_to be_nil
        end

        it "requiredにしない" do
          file_field = Nokogiri::HTML(response.body).at_css("input[type=file][name='user[face_photo]']")
          expect(file_field["required"]).to be_nil
        end

        it "2列で表示する" do
          doc = Nokogiri::HTML(response.body)
          expect(doc.at_css(".col-md-4")).not_to be_nil
          expect(doc.at_css(".col-md-8")).not_to be_nil
        end

        it "ラベルを「更新後の顔写真」にする" do
          label = Nokogiri::HTML(response.body).at_css("label[for=user_face_photo]")
          expect(label.text).to eq("更新後の顔写真")
        end
      end
    end
  end

  describe "PATCH /instructors/home/update" do
    let(:image) { fixture_file_upload("face_photo.png", "image/png") }
    let(:not_an_image) { fixture_file_upload("not_an_image.txt", "text/plain") }

    context "未ログインの場合" do
      before do
        patch instructors_update_path, params: { user: { face_photo: image } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "講師以外がログインしている場合" do
      before do
        sign_in student
        patch instructors_update_path, params: { user: { face_photo: image } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }
      end

      it "サインインページにリダイレクトする" do
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "講師がログインしている場合" do
      before { sign_in instructor }

      context "画像ファイルの場合" do
        it "顔写真を添付する" do
          patch instructors_update_path, params: { user: { face_photo: image } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.face_photo).to be_attached
        end

        it "200を返す" do
          patch instructors_update_path, params: { user: { face_photo: image } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:ok)
        end

        it "トーストで成功メッセージを表示する" do
          patch instructors_update_path, params: { user: { face_photo: image } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response.body).to include("プロフィールを更新しました。")
        end
      end

      context "画像ファイルでない場合" do
        it "顔写真を添付しない" do
          patch instructors_update_path, params: { user: { face_photo: not_an_image } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.face_photo).not_to be_attached
        end

        it "422を返す" do
          patch instructors_update_path, params: { user: { face_photo: not_an_image } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "エラーメッセージを表示する" do
          patch instructors_update_path, params: { user: { face_photo: not_an_image } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(response.body).to include("は画像ファイル")
        end
      end

      context "name, profile_text, can_instruct_*を指定した場合" do
        let(:params) do
          {
            user: {
              name: "更新後の名前",
              profile_text: "よろしくお願いします。",
              can_instruct_thai: true,
              can_instruct_lao: true
            }
          }
        end

        it "名前を更新する" do
          patch instructors_update_path, params:, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.name).to eq("更新後の名前")
        end

        it "プロフィールを更新する" do
          patch instructors_update_path, params:, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.profile_text).to eq("よろしくお願いします。")
        end

        it "指導可能な言語を更新する" do
          patch instructors_update_path, params:, headers: { "Accept" => "text/vnd.turbo-stream.html" }
          expect(instructor.reload.instructable_languages).to contain_exactly(:thai, :lao)
        end
      end
    end
  end

  describe "講師のログイン後リダイレクト" do
    it "講師でログインすると /instructors/home にリダイレクトする" do
      post user_session_path, params: { user: { email: instructor.email, password: "password123" } }
      expect(response).to redirect_to(instructors_home_path)
    end

    it "一般ユーザーでログインしても /instructors/home にリダイレクトしない" do
      post user_session_path, params: { user: { email: student.email, password: "password123" } }
      expect(response).not_to redirect_to(instructors_home_path)
    end

    it "管理者でログインしても /instructors/home にリダイレクトしない" do
      post user_session_path, params: { user: { email: admin.email, password: "password123" } }
      expect(response).not_to redirect_to(instructors_home_path)
    end
  end
end
