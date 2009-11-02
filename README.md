A base library for [Hoptoad](http://www.hoptoadapp.com/) error reporting.

Toadhopper can be used to report plain old Ruby exceptions, or to build a framework-specific gem such as [toadhopper-sinatra](http://github.com/toolmantim/toadhopper-sinatra).

    require 'toadhopper'

    Toadhopper.api_key = "YOURAPIKEY"

    error = begin; raise "Kaboom!"; rescue => e; e; end

    puts Toadhopper.post!(error)

You can install it via rubygems:

    gem install toadhopper

If you need to report different Hoptoad projects from the same Ruby process call a Toadhopper instance rather than the class methods: 

    require 'toadhopper'

    error = begin; raise "Kaboom!"; rescue => e; e; end

    puts Toadhopper("API key for project 1").post!(error)
    puts Toadhopper("API key for project 2").post!(error)
