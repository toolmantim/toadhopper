require 'helper'

class Toadhopper::TestInitialization < Test::Unit::TestCase
  MY_KEY = 'my key'

  def test_no_params
    toad = Toadhopper.new MY_KEY
    assert_toad_behavior toad
    assert_equal 'http://airbrakeapp.com', toad.notify_host
  end

  def test_https_host
    secure_host = 'https://example.com'
    toad = Toadhopper.new MY_KEY, :notify_host => secure_host
    assert_toad_behavior toad
    assert_equal secure_host, toad.notify_host
  end

  def test_secure
    toad = Toadhopper.new MY_KEY, :secure => true
    assert_toad_behavior toad
    assert_equal 'https://airbrakeapp.com', toad.notify_host
  end

  def test_secure_and_host_not_allowed
    assert_raise(ToadhopperException) do
      Toadhopper.new MY_KEY, :secure => true, :notify_host => 'http://foo.com'
    end
  end

  def assert_toad_behavior(toad)
    assert_kind_of Toadhopper, toad
    assert_equal MY_KEY, toad.api_key
  end
end