require 'rubygems'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

begin
  gem "sr-mg", "<= 0.0.5"
  require "mg"
  MG.new("toadhopper.gemspec")
rescue Gem::LoadError
end

begin
  gem "yard"
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = ['-r', 'README.md', '--files', 'LICENSE'] # optional
  end
rescue Gem::LoadError
end
