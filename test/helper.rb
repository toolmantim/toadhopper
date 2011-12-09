require 'bundler/setup'
require 'test/unit'
require 'fakeweb'
require 'toadhopper'

def reset_test_env
  FakeWeb.clean_registry
  FakeWeb.allow_net_connect = false
end

def toadhopper
  @toadhopper ||= Toadhopper.new(ENV['AIRBRAKE_API_KEY'] || ENV['HOPTOAD_API_KEY'] || "test api key", toadhopper_args)
end

def toadhopper_args
  ENV['AIRBRAKE_FULL_TEST'] ? {:secure => true} : {}
end

def error
  begin; raise "Kaboom!"; rescue => e; e end
end

reset_test_env