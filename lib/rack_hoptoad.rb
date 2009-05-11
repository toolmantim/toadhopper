gem 'rack', '>=0.9.1'
require 'rack'

root = File.expand_path(File.dirname(__FILE__))
require root + '/rack/hoptoad_notifier.rb'
