require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class Toadhopper::TestPosting < Test::Unit::TestCase
  def test_posting
    response = Toadhopper('bogus key').post!(error)
    assert_equal 422, response.status
    assert_equal ['No project exists with the given API key.'], response.errors
  end

  if ENV['HOPTOAD_API_KEY']
    def test_posting_integration
      toadhopper.filters = "HOPTOAD_API_KEY", "ROOT_PASSWORD"
      response = toadhopper.post!(error)
      assert_equal 200, response.status
      assert_equal [], response.errors
    end
  end
end
