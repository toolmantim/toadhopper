require 'helper'
require 'cgi'
require 'fakeweb'

class Toadhopper::TestDeployTracking < Test::Unit::TestCase
  BOGUS_KEY = 'bogus_key'

  def test_deploy
    response_body = 'Recorded deploy of My Awesome App to test.'
    FakeWeb.register_uri(:post, 'http://airbrake.io/deploys.txt', :body => response_body, :status => ['200', 'Ok'])
    response = Toadhopper(BOGUS_KEY).deploy!(options)
    # Check our request
    assert_equal expected_parameters, query_to_hash(FakeWeb.last_request.body)
    # Check how we capture the mock response
    assert_equal 200, response.status, response
    assert_equal response_body, response.body, response
    assert_equal [], response.errors, response
  end

  def test_fake_secure_deploy
    response_body = 'Recorded deploy of Foo to test.'
    FakeWeb.register_uri(:post, 'https://airbrake.io/deploys.txt', :body => response_body, :status => ['200', 'OK'])
    response = Toadhopper.new(BOGUS_KEY, :notify_host => 'https://airbrake.io').deploy!(options)
    # Check our request
    assert_equal expected_parameters, query_to_hash(FakeWeb.last_request.body)
    # Check how we capture the mock response
    assert_equal 200, response.status
    assert_equal response_body, response.body, response
    assert_equal [], response.errors, response
  end

  def test_deploy_integration_bad_key
    FakeWeb.allow_net_connect = true
    response = Toadhopper('bogus key').deploy!(options)
    # Check how we capture the live response
    assert_equal 403, response.status, response
    expected_error = 'could not find a project with API key'
    assert_match expected_error, response.body, response
    assert_equal 1, response.errors.size, response
    assert_match expected_error, response.errors.first, response
  end

  if toadhopper_api_key and ENV['AIRBRAKE_FULL_TEST']
    def test_deploy_integration_good_key
      FakeWeb.allow_net_connect = true
      opts = {:scm_repository => 'git://github.com/toolmantim/toadhopper.git', :scm_revision => '5e15028652023c98c70ac275b5f04bb368e04773'}
      response = toadhopper.deploy!(opts)
      # Check how we capture the live response
      assert_equal 200, response.status, response
      assert_match 'Recorded deploy', response.body, response
      assert_equal [], response.errors, response
    end
  end

  def options
    {:framework_env => 'test', :scm_revision => 3, :scm_repository => 'some/where', :username => 'phil'}
  end

  def expected_parameters
    {'api_key' => BOGUS_KEY, 'deploy[rails_env]' => 'test', 'deploy[scm_revision]' => '3', 'deploy[scm_repository]' => 'some/where', 'deploy[local_username]' => 'phil'}
  end

  def query_to_hash(query)
    Hash[CGI.unescape(query).split('&').map { |x| x.split('=') }]
  end

  # This method is called automatically after every test
  def teardown
    reset_test_env
  end
end
