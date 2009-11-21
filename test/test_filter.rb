require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class ToadHopper::Toadhopper::TestFilter < Test::Unit::TestCase
  def setup
    ToadHopper::Toadhopper.filters = nil
  end
  def test_no_filters
    assert_equal(                 {:id => "myid", :password => "mypassword"},
                 ToadHopper::Toadhopper.filter(:id => "myid", :password => "mypassword"))
  end
  def test_string_filter
    ToadHopper::Toadhopper.filters = "pass"
    assert_equal(                 {:id => "myid", :password => "[FILTERED]"},
                 ToadHopper::Toadhopper.filter(:id => "myid", :password => "mypassword"))
  end
  def test_regex_filter
    ToadHopper::Toadhopper.filters = /pas{2}/
    assert_equal(                 {:id => "myid", :password => "[FILTERED]"},
                 ToadHopper::Toadhopper.filter(:id => "myid", :password => "mypassword"))
  end
  def test_multiple_filters
    ToadHopper::Toadhopper.filters = "email", /pas{2}/
    assert_equal(                 {:id => "myid", :email => "[FILTERED]", :password => "[FILTERED]"},
                 ToadHopper::Toadhopper.filter(:id => "myid", :email => "myemail", :password => "mypassword"))
  end
end
