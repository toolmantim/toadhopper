$TESTING=true
Bundler.require_env(:test)
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rack_hoptoad'
require 'rack/mock'
