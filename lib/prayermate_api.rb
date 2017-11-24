require "prayermate_api/version"
require "httparty"
require "securerandom"

module PrayerMateApi

  class PrayerMateApiException < RuntimeError
  end

  def api(protocol, host, api_key, session = nil)
    PrayerMateApi::Api.new protocol, host, api_key, session
  end

  class Api
    attr_accessor :url_prefix, :api_key, :session_token, :email

    def initialize(protocol, host, api_key, session = nil)
      self.url_prefix = "#{protocol}://#{host}/api"
      self.api_key = api_key

      if session
        self.session_token = session[:api_token]
        self.email = session[:email]
      end
    end

    def resize_image(url, filename)
      HTTParty.post(api_path("images/resize"), body: { url: url, target_filename: filename }, headers: http_headers)
    end

    def register(promo_code, first_name, last_name, email, roles)
      data = {
          :promo_code => promo_code,
          :first_name => first_name,
          :last_name => last_name,
          :email => email,
          :password => SecureRandom.hex(8),
          :roles => roles
      }

      response = post_with_auth("auth/register", data)
      response[:password] = data[:password]
      response
    end

    def update_input_feed(feed_id, petitions, last_modified)
      HTTParty.post(api_path("input_feeds/process"), body: { feed: { id: feed_id, last_modified: last_modified }, petitions: petitions }, headers: http_headers)
    end

    def update_feed(feed_id, petitions, last_modified, url)
      HTTParty.post(api_path("feeds/process"), body: { feed: { id: feed_id, last_modified: last_modified, static_json_url: url }, petitions: petitions }, headers: http_headers)
    end

    def post_with_auth(endpoint, data)
      response = HTTParty.post(api_path(endpoint), body: data, headers: http_headers, basic_auth: auth_hash)
      process_response response
    end

    def get_with_auth(endpoint)
      response = HTTParty.get(api_path(endpoint), headers: http_headers, basic_auth: auth_hash)
      process_response response
    end

    protected

    def api_path(endpoint)
      "#{self.url_prefix}/#{endpoint}"
    end

    def process_response(response)
      begin
        body = JSON.parse(response.body)
      rescue => error
        body = { errors: error.to_s }
      end
      return body if response.code == 200

      raise PrayerMateApiException.new("Status code #{response.code}: #{body[:errors]}")
    end

    def auth_hash
      { username: email, password: session_token }
    end

    def http_headers
      { "X-API-Key" => api_key }
    end
  end
end
