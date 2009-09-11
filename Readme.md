A base library for [Hoptoad](http://www.hoptoadapp.com/) error reporting.

Toadhopper can be used to report plain old Ruby exceptions or to build a library specific gem, such as the yet-to-be-built toadhopper-sinatra and toadhopper-rack gems (they're next on my list).

## Example

    require 'rubygems'

    gem 'toadhopper'
    require 'toadhopper'

    Toadhopper.api_key = "YOURAPIKEY"

    error = begin; raise "Kaboom!"; rescue => e; e; end

    puts Toadhopper.post!(error)
