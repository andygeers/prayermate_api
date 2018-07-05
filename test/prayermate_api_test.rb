require "test_helper"

class PrayermateApiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::PrayerMateApi::VERSION
  end

  PROTOCOL = "http"
  HOST = "localhost"
  API_KEY = "a1b2c3d4"
  TOKEN = "xyz789"
  EMAIL = "ed@example.com"
  SESSION = { api_token: TOKEN, email: EMAIL }

  describe PrayerMateApi do
    before do
      @api = PrayerMateApi.api PROTOCOL, HOST, API_KEY, SESSION
    end

    describe "when calling the api method" do
      it "must create an api object" do
        api = PrayerMateApi.api PROTOCOL, HOST, API_KEY
        refute_nil api
      end

      it "must create the url prefix" do
        api = PrayerMateApi.api PROTOCOL, HOST, API_KEY
        assert_equal "#{PROTOCOL}://#{HOST}/api", api.url_prefix
      end

      it "must make the api key available" do
        api = PrayerMateApi.api PROTOCOL, HOST, API_KEY
        assert_equal API_KEY, api.api_key
      end

      describe "with a session hash" do
        it "must make the session token available" do
          api = PrayerMateApi.api PROTOCOL, HOST, API_KEY, SESSION
          assert_equal TOKEN, api.session_token
        end

        it "must make the email available" do
          api = PrayerMateApi.api PROTOCOL, HOST, API_KEY, SESSION
          assert_equal EMAIL, api.email
        end
      end

      describe "with nil parameters" do
        it "must raise a PrayerMateApiException" do
          assert_raises PrayerMateApi::PrayerMateApiException do
            PrayerMateApi.api nil, HOST, API_KEY
          end

          assert_raises PrayerMateApi::PrayerMateApiException do
            PrayerMateApi.api PROTOCOL, nil, API_KEY
          end

          assert_raises PrayerMateApi::PrayerMateApiException do
            PrayerMateApi.api PROTOCOL, HOST, nil
          end
        end
      end
    end

    describe "when asking for the api path" do
      it "must construct it properly" do
        endpoint = "test"
        expected_api_path = "#{PROTOCOL}://#{HOST}/api/#{endpoint}"
        assert_equal expected_api_path, @api.send(:api_path, endpoint)
      end
    end

    describe "when asking for the auth hash" do
      it "must construct it properly" do
        expected_auth_hash = { username: EMAIL, password: TOKEN }
        assert_equal expected_auth_hash, @api.send(:auth_hash)
      end
    end

    describe "when asking for the HTTP headers" do
      it "must construct them properly" do
        expected_http_headers = { "X-API-Key" => API_KEY }
        assert_equal expected_http_headers, @api.send(:http_headers)
      end
    end

  end
end
