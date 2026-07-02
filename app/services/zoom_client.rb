require "net/http"
require "uri"
require "json"

class ZoomClient
  ApiError = Class.new(StandardError)

  TOKEN_URL = URI("https://zoom.us/oauth/token")
  MEETINGS_URL = URI("https://api.zoom.us/v2/users/me/meetings")

  def create_meeting(topic:, start_time:, duration: 50)
    token = fetch_access_token

    http = Net::HTTP.new(MEETINGS_URL.host, MEETINGS_URL.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(MEETINGS_URL)
    request["Authorization"] = "Bearer #{token}"
    request["Content-Type"] = "application/json"
    request.body = {
      topic: topic,
      type: 2,
      start_time: start_time.utc.iso8601,
      duration: duration
    }.to_json

    response = http.request(request)
    raise ApiError, "#{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)["join_url"]
  end

  private

  def fetch_access_token
    creds = Rails.application.credentials.zoom!

    url = TOKEN_URL.dup
    url.query = URI.encode_www_form(
      grant_type: "account_credentials",
      account_id: creds.account_id!
    )

    http = Net::HTTP.new(TOKEN_URL.host, TOKEN_URL.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request.basic_auth(creds.client_id!, creds.client_secret!)

    response = http.request(request)
    raise ApiError, "#{response.code} #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)["access_token"]
  end
end