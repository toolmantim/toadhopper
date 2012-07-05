require 'helper'

class Toadhopper::TestInitialization < Test::Unit::TestCase
  MY_KEY = 'my key'

  def test_no_params
    toad = Toadhopper.new MY_KEY
    assert_toad_behavior toad
    assert_match 'http://airbrake.io', toad.error_url.to_s
    assert ! toad.secure?
  end

  def test_http_host
    toad = Toadhopper.new MY_KEY, :notify_host => 'http://foo.com'
    assert_toad_behavior toad
    assert_match 'http://foo.com', toad.deploy_url.to_s
    assert ! toad.secure?
  end

  def test_https_host
    secure_host = 'https://example.com'
    toad = Toadhopper.new MY_KEY, :notify_host => secure_host
    assert_toad_behavior toad
    assert_match secure_host, toad.error_url.to_s
    assert toad.secure?
  end

  def test_vague_host_not_allowed
    assert_raise(ToadhopperException) do
      Toadhopper.new MY_KEY, :notify_host => 'toadhopper.net'
    end
  end

  def test_http_transport
    transport = Net::HTTP.new 'airbrake.io'
    toad = Toadhopper.new MY_KEY, :transport => transport
    assert ! toad.secure?
    assert_same transport, toad.connection(toad.error_url)
  end

  def test_https_transport
    transport = Net::HTTP.new 'foo.com', 443
    transport.use_ssl = true
    toad = Toadhopper.new MY_KEY, :transport => transport
    assert toad.secure?
    assert_same transport, toad.connection(toad.error_url)
  end

  def test_transport_and_url_conflict
    transport = Net::HTTP.new 'domain1.com'
    assert_raise(ToadhopperException) do
      Toadhopper.new MY_KEY, :notify_host => 'http://domain2.com', :transport => transport
    end
  end

  def test_ca_file
    assert File.exists? Toadhopper::CA_FILE
  end

  def assert_toad_behavior(toad)
    assert_kind_of Toadhopper, toad
    assert_equal MY_KEY, toad.api_key
  end
end