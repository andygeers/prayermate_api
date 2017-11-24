require "prayermate_api/version"
require "httparty"

module PrayerMateApi

  # TODO: replace with environment variable
  API_KEY = "nonsense"

  def api(protocol, host)
    PrayerMateApi::Api.new protocol, host
  end

  class Api
    attr_accessor :url_prefix

    def initialize(protocol, host)
      self.url_prefix = "#{protocol}://#{host}/api"
    end

    def resize_image(url, filename)
      api_path = "#{self.url_prefix}/images/resize"
      HTTParty.post(api_path, :body => { :url => url, :target_filename => filename }, :headers => http_headers)
    end

    def update_input_feed(feed_id, petitions, last_modified)
      api_path = "#{self.url_prefix}/input_feeds/process"
      HTTParty.post(api_path, :body => { :feed => { :id => feed_id, :last_modified => last_modified }, :petitions => petitions }, :headers => http_headers)
    end

    protected

    def http_headers
      { "X-API-Key" => API_KEY }
    end
  end
end
