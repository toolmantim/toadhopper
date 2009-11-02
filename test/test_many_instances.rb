require File.dirname(__FILE__) + "/../lib/toadhopper"

require 'test/unit'

class Toadhopper::TestManyInstances < Test::Unit::TestCase
  def test_multiple_instances_with_different_api_keys
    toad_one = Toadhopper("api key 1")
    toad_two = Toadhopper("api key 2")
    assert_equal "api key 1", toad_one.api_key
    assert_equal "api key 2", toad_two.api_key
  end
end
