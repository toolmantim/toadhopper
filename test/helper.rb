require 'bundler/setup'
require 'test/unit'
require 'fakeweb'
require 'toadhopper'

FakeWeb.allow_net_connect = true

def toadhopper
  @toadhopper ||= Toadhopper.new(ENV['AIRBRAKE_API_KEY'] || ENV['HOPTOAD_API_KEY'] || "test api key", toadhopper_args)
end

def toadhopper_args
  ENV['SECURE'] ? {:secure => true} : {}
end

def error
  begin; raise "Kaboom!"; rescue => e; e end
end
