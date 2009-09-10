Toadhopper
----------

A base library for Hoptoad reporting.

You can use this to report plain old Ruby exceptions, or to build a library specific gem such as the yet-to-be-built toadhopper-sinatra and toadhopper-rack gems (that's next on my list).

## Example

     require 'rubygems'

     gem 'toadhopper'
     require 'toadhopper'

     Toadhopper.api_key = "YOURAPIKEY"

     error = begin; raise "Kaboom!"; rescue => e; e; end

     STDERR.puts Toadhopper.post!(error)
