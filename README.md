A base library for [Hoptoad](http://www.hoptoadapp.com/) error reporting.

Toadhopper can be used to report plain old Ruby exceptions, or to build a framework-specific gem such as [toadhopper-sinatra](http://github.com/toolmantim/toadhopper-sinatra).

    require 'toadhopper'

    Toadhopper.api_key = "YOURAPIKEY"

    error = begin; raise "Kaboom!"; rescue => e; e; end

    puts Toadhopper.post!(error)

You can install it via rubygems:

    gem install toadhopper

## Multi-toad

If you need to report errors to different Hoptoad projects from the same Ruby process create a Toadhopper instance with `Toadhopper('project api key')`. For example: 

    require 'toadhopper'

    error = begin; raise "Kaboom!"; rescue => e; e; end

    puts Toadhopper("API key for project 1").post!(error)
    puts Toadhopper("API key for project 2").post!(error)

## Contributors

* [Tim Lucas](http://github.com/toolmantim)
* [Samuel Tesla](http://github.com/stesla)
