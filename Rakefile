Bundler.setup(:development, :test)
Bundler.require(:development, :test)

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

Jeweler::Tasks.new do |s|
  s.name     = "toadhopper"
  s.summary  = "Post error notifications to Hoptoad"
  s.email    = "t.lucas@toolmantim.com"
  s.homepage = "http://github.com/toolmantim/toadhopper"
  s.authors  = ["Tim Lucas", "Samuel Tesla", "Corey Donohoe", "Andre Arko", "Theo Hultberg"]
  s.extra_rdoc_files  = ["README.md", "LICENSE"]
  s.executables = nil # stops jeweler automatically adding bin/*

  require File.join(File.dirname(__FILE__), 'lib', 'toadhopper')
  s.version  = Toadhopper::VERSION
end
