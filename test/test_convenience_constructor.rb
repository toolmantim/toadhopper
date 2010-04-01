require 'helper'

class Toadhopper::TestConvenienceConstructor < Test::Unit::TestCase
  def test_convenience_constructor
    assert_kind_of Toadhopper, Toadhopper.new('somekey')
  end
end
