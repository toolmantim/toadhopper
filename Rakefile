Bundler.require_env(:development)
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

MG.new("toadhopper.gemspec")
