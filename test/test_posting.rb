require 'helper'

class Toadhopper::TestPosting < Test::Unit::TestCase
  def test_posting
    response = Toadhopper('bogus key').post!(error)
    assert_equal 422, response.status
    assert_equal ['No project exists with the given API key.'], response.errors
  end

  if ENV['AIRBRAKE_API_KEY']
    def test_posting_integration
      toadhopper.filters = "AIRBRAKE_API_KEY", "ROOT_PASSWORD"
      response = toadhopper.post!(error)
      assert_equal 200, response.status
      assert_equal [], response.errors
    end
  end
end
