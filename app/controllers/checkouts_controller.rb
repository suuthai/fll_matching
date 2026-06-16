class CheckoutsController < ApplicationController
  include HomeHelper

  before_action :authenticate_user!, only: [ :create, :success, :cancel ]
  skip_before_action :verify_authenticity_token, only: [ :webhook ]

  def create
    plan = HomeHelper::TICKET_PLANS[params[:plan]]
    return redirect_to root_path, alert: "無効なプランです" unless plan

    checkout_session = Stripe::Checkout::Session.create(
      mode: "payment",
      line_items: [ {
        quantity: 1,
        price_data: {
          currency: "jpy",
          unit_amount: plan[:price],
          product_data: { name: plan[:label] }
        },
        tax_rates: [ Rails.configuration.x.stripe_jp_tax_rate_id ]
      } ],
      metadata: {
        user_id: current_user.id,
        tickets_count: plan[:tickets_count]
      },
      success_url: checkout_success_url,
      cancel_url: checkout_cancel_url
    )

    redirect_to checkout_session.url, allow_other_host: true
  end

  def success
    redirect_to root_path, notice: "チケットを購入しました。"
  end

  def cancel
    redirect_to root_path, notice: "チケットの購入をキャンセルしました。"
  end

  def webhook
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      return head :bad_request
    end

    if event["type"] == "checkout.session.completed"
      stripe_session = event["data"]["object"]
      user_id = stripe_session["metadata"]["user_id"]
      tickets_count = stripe_session["metadata"]["tickets_count"].to_i

      user = User.find_by(id: user_id)
      user&.increment!(:tickets_count, tickets_count)
    end

    head :ok
  end
end