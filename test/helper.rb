require 'bundler/setup'
require 'test/unit'
require 'fakeweb'
require 'toadhopper'

FakeWeb.allow_net_connect = true

def toadhopper
  @toadhopper ||= Toadhopper.new(ENV['HOPTOAD_API_KEY'] || "test api key")
end

def error
  begin; raise "Kaboom!"; rescue => e; e end
end
