A base library for [Hoptoad](http://www.hoptoadapp.com/) error reporting.

Toadhopper can be used to report plain old Ruby exceptions, or to build a framework-specific gem such as [toadhopper-sinatra](http://github.com/toolmantim/toadhopper-sinatra).

    require 'toadhopper'

    Toadhopper.api_key = "YOURAPIKEY"

    error = begin; raise "Kaboom!"; rescue => e; e; end

    puts Toadhopper.post!(error)

You can install it via rubygems:

    gem install toadhopper
