require File.dirname(__FILE__) + "/../lib/toadhopper"

require 'test/unit'

class Toadhopper::TestFilter < Test::Unit::TestCase
  def setup
    Toadhopper.filters = nil
  end
  def test_no_filters
    assert_equal(                 {:id => "myid", :password => "mypassword"},
                 Toadhopper.filter(:id => "myid", :password => "mypassword"))
  end
  def test_string_filter
    Toadhopper.filters = "pass"
    assert_equal(                 {:id => "myid", :password => "[FILTERED]"},
                 Toadhopper.filter(:id => "myid", :password => "mypassword"))
  end
  def test_regex_filter
    Toadhopper.filters = /pas{2}/
    assert_equal(                 {:id => "myid", :password => "[FILTERED]"},
                 Toadhopper.filter(:id => "myid", :password => "mypassword"))
  end
  def test_multiple_filters
    Toadhopper.filters = "email", /pas{2}/
    assert_equal(                 {:id => "myid", :email => "[FILTERED]", :password => "[FILTERED]"},
                 Toadhopper.filter(:id => "myid", :email => "myemail", :password => "mypassword"))
  end
end
