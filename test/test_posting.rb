require 'helper'

class Toadhopper::TestPosting < Test::Unit::TestCase
  def test_mock_successful_posting
    key = 'lolc@tz'
    response_body = posting_response_good
    FakeWeb.register_uri(:post, 'http://airbrake.io/notifier_api/v2/notices', :body => response_body, :status => ['200', 'OK'])
    response = Toadhopper(key).post!(error)
    # Check our request
    assert_match key, FakeWeb.last_request.body, FakeWeb.last_request.body
    assert_valid_airbrake_xml FakeWeb.last_request.body
    # Check how we capture the mock response
    assert_equal response_body, response.body, response
    assert_successful_response response
  end

  def test_mock_unsuccessful_posting
    key = 'roflcopt3r'
    response_body = posting_response_bad_apikey
    FakeWeb.register_uri(:post, 'http://airbrake.io/notifier_api/v2/notices', :body => response_body, :status => ['422', '422 status code 422'])
    response = Toadhopper(key).post! error
    # Check how we capture the mock response
    assert_equal response_body, response.body, response
    assert_failed_response response
  end

  def test_posting
    FakeWeb.allow_net_connect = true
    response = Toadhopper('bogus key').post!(error)
    # Check how we capture the live response
    assert_failed_response response
  end

  def test_posting_transport
    FakeWeb.allow_net_connect = true
    response = Toadhopper.new('bogus key', :transport => transport).post!(error)
    assert_equal 1, response.errors.length, response
  end

  if toadhopper_api_key
    def test_posting_integration
      FakeWeb.allow_net_connect = true
      toad = toadhopper
      toad.filters = "AIRBRAKE_API_KEY", "ROOT_PASSWORD"
      assert_successful_response toad.post! error
    end

    def test_posting_transport_integration
      FakeWeb.allow_net_connect = true
      toad = Toadhopper.new toadhopper_api_key, :transport => transport
      assert_successful_response toad.post! error
    end
  end

  def assert_successful_response(response)
    assert_equal 200, response.status, response
    assert_match '</id>', response.body, response
    assert_equal [], response.errors, response
  end

  def assert_failed_response(response, code = 422)
    assert_equal code, response.status, response
    assert_respond_to response.errors, :each_with_index, response
    assert_equal 1, response.errors.length, response
  end

  def transport
    port = nil
    port = Net::HTTP.https_default_port if ENV['AIRBRAKE_FULL_TEST']
    transport = Net::HTTP.new 'airbrake.io', port
    transport.read_timeout = 7 # seconds
    transport.open_timeout = 7 # seconds
    if ENV['AIRBRAKE_FULL_TEST']
      transport.use_ssl     = true
      transport.ca_file     = Toadhopper::CA_FILE
      transport.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
    transport
  end

  # This method is called automatically after every test
  def teardown
    reset_test_env
  end
end
