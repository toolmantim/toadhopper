require File.dirname(__FILE__) + "/../lib/toadhopper/test"

require 'test/unit'

class Toadhopper::TestTest < Test::Unit::TestCase
  include Toadhopper::Test::Methods
  def test_stub_toadhopper_post!
    stub_toadhopper_post!
    Toadhopper.post!(:error, :options, :header_options)
    assert_equal [:error, :options, :header_options], last_toadhopper_post_arguments
  end
end
