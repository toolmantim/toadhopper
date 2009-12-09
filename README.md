A base library for [Hoptoad](http://www.hoptoadapp.com/) error reporting.

Toadhopper can be used to report plain old Ruby exceptions, or to build a framework-specific gem such as [toadhopper-sinatra](http://github.com/toolmantim/toadhopper-sinatra).

    require 'toadhopper'

    dispatcher = Toadhopper::Dispatcher.new("YOURAPIKEY")

    error = begin; raise "Kaboom!"; rescue => e; e; end

    puts dispatcher.post!(error)

You can install it via rubygems:

    gem install toadhopper

## Development

    % git clone git://github.com/toolmantim/toadhopper.git
    % cd toadhopper
    % gem bundle
    % bin/rake test
    % bin/rake doc && open doc/index.html

## Contributors

* [Tim Lucas](http://github.com/toolmantim)
* [Samuel Tesla](http://github.com/stesla)
* [atmos](http://github.com/atmos)
