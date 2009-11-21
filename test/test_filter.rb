require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class ToadHopper::Dispatcher::TestFilter < Test::Unit::TestCase
  def test_no_filters
    dispatcher = ToadHopper::Dispatcher.new
    assert_equal(                 {:id => "myid", :password => "mypassword"},
                 dispatcher.filter(:id => "myid", :password => "mypassword"))
  end

  def test_string_filter
    dispatcher = ToadHopper::Dispatcher.new
    dispatcher.filters = "pass"
    assert_equal(                 {:id => "myid", :password => "[FILTERED]"},
                 dispatcher.filter(:id => "myid", :password => "mypassword"))
  end

  def test_regex_filter
    dispatcher = ToadHopper::Dispatcher.new
    dispatcher.filters = /pas{2}/
    assert_equal(                 {:id => "myid", :password => "[FILTERED]"},
                 dispatcher.filter(:id => "myid", :password => "mypassword"))
  end

  def test_multiple_filters
    dispatcher = ToadHopper::Dispatcher.new
    dispatcher.filters = "email", /pas{2}/
    assert_equal(                 {:id => "myid", :email => "[FILTERED]", :password => "[FILTERED]"},
                 dispatcher.filter(:id => "myid", :email => "myemail", :password => "mypassword"))
  end
end
