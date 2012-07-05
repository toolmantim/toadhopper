require 'bundler/setup'
require 'test/unit'
require 'fakeweb'
require 'toadhopper'
require 'xml'

def reset_test_env
  FakeWeb.clean_registry
  FakeWeb.allow_net_connect = false
end

def toadhopper
  api_key = toadhopper_api_key || 'test api key'
  Toadhopper.new api_key, toadhopper_args
end

def toadhopper_api_key
  ENV['AIRBRAKE_API_KEY'] || ENV['HOPTOAD_API_KEY']
end

def toadhopper_args
  ENV['AIRBRAKE_FULL_TEST'] ? {:notify_host => 'https://airbrake.io'} : {}
end

def assert_valid_airbrake_xml(body)
  # prepare schema for validation
  xsd_path = File.expand_path File.join('resources', 'airbrake_2_2.xsd'),
    File.dirname(__FILE__)
  schema = XML::Schema.document XML::Document.file xsd_path
  # validate xml document
  begin
    assert XML::Document.string(body).validate_schema schema
  rescue XML::Error
    warn "INVALID Airbrake xml:\n #{body}"
    raise
  end
end

def posting_response_good
'<notice>
<id>d87i3bc8-1854-f937-184b-e2d93711cad3</id>
<url>http://airbrake.io/locate/d87i3bc8-1854-f937-184b-e2d93711cad3</url>
</notice>'
end

def posting_response_bad_apikey
  'We could not find a project with API key of foo.  Please double check your airbrake configuration.'
end

def error
  begin; raise "Kaboom!"; rescue => e; e end
end

reset_test_env