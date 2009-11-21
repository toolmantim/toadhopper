require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class ToadHopper::Toadhopper::TestSetters < Test::Unit::TestCase
  def setup
    ToadHopper::Toadhopper.api_key = nil
    ToadHopper::Toadhopper.filters = nil
  end
  def test_setting_api_key
    ToadHopper::Toadhopper.api_key = "abc123"
    assert_equal "abc123", ToadHopper::Toadhopper.api_key
  end
  def test_setting_single_filter
    ToadHopper::Toadhopper.filters = /password/
    assert_equal [/password/], ToadHopper::Toadhopper.filters
  end
  def test_setting_multple_filters
    ToadHopper::Toadhopper.filters = /password/, /email/
    assert_equal [/password/, /email/], ToadHopper::Toadhopper.filters
  end
end
