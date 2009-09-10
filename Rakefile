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
rescue LoadError
end
