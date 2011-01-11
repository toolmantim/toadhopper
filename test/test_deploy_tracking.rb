require 'helper'
require 'cgi'
require 'fakeweb'

class Toadhopper::TestDeployTracking < Test::Unit::TestCase
  def test_deploy
    FakeWeb.register_uri(:post, 'http://hoptoadapp.com/deploys.txt', :status => ['200', 'Ok'])
    options = {:framework_env => 'test', :scm_revision => 3, :scm_repository => 'some/where', :username => 'phil'}
    response = Toadhopper('bogus key').deploy!(options)
    request = FakeWeb.last_request
    expected_parameters = {'api_key' => 'bogus key', 'deploy[rails_env]' => 'test', 'deploy[scm_revision]' => '3', 'deploy[scm_repository]' => 'some/where', 'deploy[local_username]' => 'phil'}
    assert_equal 200, response.status
    assert_equal expected_parameters, Hash[CGI.unescape(FakeWeb.last_request.body).split('&').map { |x| x.split('=') }]
  end
end
