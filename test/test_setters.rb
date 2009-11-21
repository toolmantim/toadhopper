require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class Toadhopper::TestSetters < Test::Unit::TestCase
  def setup
    Toadhopper.api_key = nil
    Toadhopper.filters = nil
  end
  def test_setting_api_key
    Toadhopper.api_key = "abc123"
    assert_equal "abc123", Toadhopper.api_key
  end
  def test_setting_single_filter
    Toadhopper.filters = /password/
    assert_equal [/password/], Toadhopper.filters
  end
  def test_setting_multple_filters
    Toadhopper.filters = /password/, /email/
    assert_equal [/password/, /email/], Toadhopper.filters
  end
end
