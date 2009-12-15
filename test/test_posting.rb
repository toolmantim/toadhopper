require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class ToadHopper::TestPosting < Test::Unit::TestCase
  def test_posting
    toadhopper = ToadHopper.new("abc123")
    error = begin; raise "Kaboom!"; rescue => e; e end

    response = toadhopper.post!(error)
    assert_equal 422, response.status
    assert_equal ['No project exists with the given API key.'], response.errors
  end

  if ENV['HOPTOAD_API_KEY']
    def test_posting_integration
      toadhopper = ToadHopper.new(ENV['HOPTOAD_API_KEY'])
      error = begin; raise "Kaboom!"; rescue => e; e end

      response = toadhopper.post!(error)
      assert_equal 200, response.status
      assert_equal [], response.errors
    end
  end
end
