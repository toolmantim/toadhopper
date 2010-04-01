Bundler.setup(:test)
Bundler.require(:test)

require 'test/unit'
require "toadhopper"

def toadhopper
  @toadhopper ||= Toadhopper.new(ENV['HOPTOAD_API_KEY'] || "test api key")
end

def error
  begin; raise "Kaboom!"; rescue => e; e end
end
