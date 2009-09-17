Gem::Specification.new do |s|
  s.name              = "toadhopper"
  s.version           = "0.6"
  s.extra_rdoc_files  = ["README.md", "LICENSE"]
  s.summary           = "Post error notifications to Hoptoad"
  s.description       = s.summary
  s.authors           = ["Tim Lucas"]
  s.email             = "t.lucas@toolmantim.com"
  s.homepage          = "http://github.com/toolmantim/toadhopper"
  s.require_path      = "lib"
  s.rubyforge_project = "toadhopper"
  s.files             = %w(
                          README.md
                          Rakefile
                          LICENSE
                          lib/toadhopper.rb
                          test/test_filter.rb
                          test/test_notice_params.rb
                          test/test_setters.rb
                        )
  s.has_rdoc          = true
end
