Bundler.require_env(:test)
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rack/hoptoad'
require 'rack/mock'
