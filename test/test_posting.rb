require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class Toadhopper::TestPosting < Test::Unit::TestCase
  def test_posting
    Toadhopper.api_key = ENV['MY_HOPTOAD_API_KEY'] || "abc123"
    error = begin; raise "Kaboom!"; rescue => e; e end

    assert !Toadhopper.post!(error)
  end
end
