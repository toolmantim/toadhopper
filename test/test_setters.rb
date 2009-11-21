require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class ToadHopper::Dispatcher::TestSetters < Test::Unit::TestCase
  def test_setting_api_key
    dispatcher = ToadHopper::Dispatcher.new('abc123')
    assert_equal "abc123", dispatcher.api_key
  end
  def test_setting_single_filter
    dispatcher = ToadHopper::Dispatcher.new
    dispatcher.filters = /password/
    assert_equal [/password/], dispatcher.filters
  end
  def test_setting_multple_filters
    dispatcher = ToadHopper::Dispatcher.new
    dispatcher.filters = /password/, /email/
    assert_equal [/password/, /email/], dispatcher.filters
  end
end
