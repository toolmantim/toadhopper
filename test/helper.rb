Bundler.setup(:runtime, :test)
Bundler.require(:runtime, :test)

require File.expand_path("../../lib/toadhopper", __FILE__)

def toadhopper
  @toadhopper ||= ToadHopper.new(ENV['HOPTOAD_API_KEY'] || "test api key")
end
