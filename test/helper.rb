require 'bundler/setup'
require 'test/unit'
require 'fakeweb'
require 'toadhopper'

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

def error
  begin; raise "Kaboom!"; rescue => e; e end
end

reset_test_env