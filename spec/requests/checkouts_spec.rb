require "rails_helper"

RSpec.describe "Checkouts", type: :request do
  describe "POST /checkouts" do
    let(:user) { create(:user) }
    before { sign_in user }

    context "有効なプランを指定した場合" do
      let(:stripe_session) { double("Stripe::Checkout::Session", url: "https://checkout.stripe.com/test") }

      before do
        allow(Stripe::Checkout::Session).to receive(:create).and_return(stripe_session)
      end

      it "Stripeの決済ページにリダイレクトする" do
        post checkouts_path(language: :thai), params: { plan: "only_one" }
        expect(response).to redirect_to("https://checkout.stripe.com/test")
      end

      it "チケット枚数と金額が正しくStripeに渡される" do
        expect(Stripe::Checkout::Session).to receive(:create).with(
          hash_including(
            line_items: [ hash_including(
              price_data: hash_including(unit_amount: 2000),
              tax_rates: [ "txr_test" ]
            ) ],
            metadata: hash_including(user_id: user.id, tickets_count: 1)
          )
        ).and_return(stripe_session)

        post checkouts_path(language: :thai), params: { plan: "only_one" }
      end
    end

    context "無効なプランを指定した場合" do
      it "ルートページにリダイレクトしてアラートを表示する" do
        post checkouts_path(language: :thai), params: { plan: "invalid_plan" }
        expect(response).to redirect_to(language_root_path(:thai))
        expect(flash[:alert]).to eq("無効なプランです")
      end
    end
  end

  describe "POST /stripe/webhook" do
    let(:user) { create(:user, tickets_count: 0) }

    def post_webhook(event)
      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
      post "/stripe/webhook",
        params: "{}",
        headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "test_sig" }
    end

    context "checkout.session.completed イベントの場合" do
      let(:event) do
        {
          "type" => "checkout.session.completed",
          "data" => {
            "object" => {
              "metadata" => {
                "user_id" => user.id.to_s,
                "tickets_count" => "3"
              }
            }
          }
        }
      end

      it "200を返す" do
        post_webhook(event)
        expect(response).to have_http_status(:ok)
      end

      it "ユーザーのtickets_countを加算する" do
        post_webhook(event)
        expect(user.reload.tickets_count).to eq(3)
      end
    end

    context "署名が無効な場合" do
      before do
        allow(Stripe::Webhook).to receive(:construct_event)
          .and_raise(Stripe::SignatureVerificationError.new("Invalid signature", "{}"))
      end

      it "400を返す" do
        post "/stripe/webhook",
          params: "{}",
          headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "bad_sig" }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "checkout.session.completed 以外のイベントの場合" do
      let(:event) { { "type" => "payment_intent.created", "data" => { "object" => {} } } }

      it "tickets_countを変更しない" do
        expect { post_webhook(event) }.not_to change { user.reload.tickets_count }
      end
    end
  end
end
