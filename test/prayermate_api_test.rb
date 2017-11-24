require "test_helper"

class PrayermateApiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::PrayermateApi::VERSION
  end
end
