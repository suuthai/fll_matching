RSpec.configure do |config|
  config.before(:each) do
    Rails.configuration.x.stripe_jp_tax_rate_id = "txr_test"
  end
end
