require 'helper'

class Toadhopper::TestInitialization < Test::Unit::TestCase
  MY_KEY = 'my key'

  def test_no_params
    toad = Toadhopper.new MY_KEY
    assert_toad_behavior toad
    assert_match 'http://airbrake.io', toad.error_url.to_s
    assert ! toad.secure
  end

  def test_http_host
    toad = Toadhopper.new MY_KEY, :notify_host => 'http://foo.com'
    assert_toad_behavior toad
    assert_match 'http://foo.com', toad.deploy_url.to_s
    assert ! toad.secure
  end

  def test_https_host
    secure_host = 'https://example.com'
    toad = Toadhopper.new MY_KEY, :notify_host => secure_host
    assert_toad_behavior toad
    assert_match secure_host, toad.error_url.to_s
    assert_equal({}, toad.secure)
  end

  def test_secure
    toad = Toadhopper.new MY_KEY, :secure => true
    assert_toad_behavior toad
    assert_match 'https://airbrake.io', toad.error_url.to_s
    assert_equal({}, toad.secure)
  end

  def test_vague_host_not_allowed
    assert_raise(ToadhopperException) do
      Toadhopper.new MY_KEY, :notify_host => 'toadhopper.net'
    end
  end

  def test_secure_and_https_host
    toad = Toadhopper.new MY_KEY, :secure => { :ca_bundle => :system }, :notify_host => 'https://foo.com'
    assert_toad_behavior toad
    assert_match 'https://foo.com', toad.error_url.to_s
    assert_equal :system, toad.secure[:ca_bundle]
  end

  def test_secure_and_http_host
    toad = Toadhopper.new MY_KEY, :secure => true, :notify_host => 'http://foo.com'
    assert_toad_behavior toad
    assert_match 'https://foo.com', toad.error_url.to_s
    assert_equal({}, toad.secure)
  end

  def assert_toad_behavior(toad)
    assert_kind_of Toadhopper, toad
    assert_equal MY_KEY, toad.api_key
  end
end