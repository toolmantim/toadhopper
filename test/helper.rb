require File.expand_path("../../vendor/gems/environment.rb", __FILE__)
Bundler.require_env(:test)

require File.expand_path("../../lib/toadhopper", __FILE__)

def toadhopper
  @toadhopper ||= ToadHopper.new("test api key")
end
