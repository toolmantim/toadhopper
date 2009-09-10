Gem::Specification.new do |s|
  s.name             = "toadhopper"
  s.version          = "0.3"
  s.extra_rdoc_files = ["Readme.md"]
  s.summary          = "Library for posting Hoptoad notifications"
  s.description      = s.summary
  s.authors          = ["Tim Lucas"]
  s.email            = "t.lucas@toolmantim.com"
  s.homepage         = "http://github.com/toolmantim/toadhopper"
  s.require_path     = "lib"
  s.files            = %w(
                         Readme.md
                         Rakefile
                         lib/toadhopper.rb
                         lib/toadhopper/test.rb
                         test/test_filter.rb
                         test/test_notice_params.rb
                         test/test_setters.rb
                         test/test_test.rb
                       )
  s.has_rdoc         = true
end
