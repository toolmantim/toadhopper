gem 'rack', '~>1.0.0'
require 'rack'

root = File.expand_path(File.dirname(__FILE__))
require root + '/rack/hoptoad_notifier.rb'
