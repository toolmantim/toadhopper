require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class ToadHopper::TestFilters < Test::Unit::TestCase
  def test_no_filters
    assert_equal(                {:id => "myid", :password => "mypassword"},
                 toadhopper.clean(:id => "myid", :password => "mypassword"))
  end

  def test_string_filter
    toadhopper.filters = "pass"
    assert_equal(                {:id => "myid", :password => "[FILTERED]"},
                 toadhopper.clean(:id => "myid", :password => "mypassword"))
  end

  def test_regex_filter
    toadhopper.filters = /pas{2}/
    assert_equal(                {:id => "myid", :password => "[FILTERED]"},
                 toadhopper.clean(:id => "myid", :password => "mypassword"))
  end

  def test_multiple_filters
    toadhopper.filters = "email", /pas{2}/
    assert_equal(                 {:id => "myid", :email => "[FILTERED]", :password => "[FILTERED]"},
                 toadhopper.clean(:id => "myid", :email => "myemail", :password => "mypassword"))
  end
end
