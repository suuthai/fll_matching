# SECRET_KEY_BASE_DUMMY is set by the Dockerfile when precompiling assets at build time,
# when credentials can't be decrypted and Stripe isn't reachable yet.
unless ENV["SECRET_KEY_BASE_DUMMY"]
  Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

  tax_rate_id = Rails.application.credentials.dig(:stripe, :tax_rate_id)
  raise "stripe.tax_rate_id is not set in credentials" if tax_rate_id.blank?

  rate = Stripe::TaxRate.retrieve(tax_rate_id)
  raise "Stripe tax rate #{tax_rate_id} is not active" unless rate.active

  Rails.configuration.x.stripe_jp_tax_rate_id = rate.id
end
