require 'helper'
require 'cgi'
require 'fakeweb'

class Toadhopper::TestDeployTracking < Test::Unit::TestCase
  def test_deploy
    response_body = 'Recorded deploy of My Awesome App to test.'
    FakeWeb.register_uri(:post, 'http://airbrakeapp.com/deploys.txt', :body => response_body, :status => ['200', 'Ok'])
    response = Toadhopper('bogus key').deploy!(options)
    # Check our request
    expected_parameters = {'api_key' => 'bogus key', 'deploy[rails_env]' => 'test', 'deploy[scm_revision]' => '3', 'deploy[scm_repository]' => 'some/where', 'deploy[local_username]' => 'phil'}
    assert_equal expected_parameters, Hash[CGI.unescape(FakeWeb.last_request.body).split('&').map { |x| x.split('=') }]
    # Check how we capture the mock response
    assert_equal 200, response.status, response
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

  if ENV['AIRBRAKE_API_KEY'] and not ENV['SECURE'] # @TODO Make deployments work under SSL
    def test_deploy_integration_good_key
      FakeWeb.allow_net_connect = true
      opts = {:scm_repository => 'git://github.com/toolmantim/toadhopper.git', :scm_revision => 'a4aa47e5146c5a4cf84d87654efe53934b99daad'}
      response = toadhopper.deploy!(opts)
      # Check how we capture the live response
      assert_equal 200, response.status, response
      assert_match 'Recorded deploy', response.body, response
      assert_equal [], response.errors, response
    end
  end

  def options
    @options ||= {:framework_env => 'test', :scm_revision => 3, :scm_repository => 'some/where', :username => 'phil'}
  end

  # This method is called automatically after every test
  def teardown
    reset_test_env
  end
end
