A base library for [Hoptoad](http://www.hoptoadapp.com/) error reporting.

Toadhopper can be used to report plain old Ruby exceptions, or to build a framework-specific gem such as [toadhopper-sinatra](http://github.com/toolmantim/toadhopper-sinatra).

    require 'toadhopper'

    dispatcher = Toadhopper::Dispatcher.new("YOURAPIKEY")

    error = begin; raise "Kaboom!"; rescue => e; e; end

    puts dispatcher.post!(error)

You can install it via rubygems:

    gem install toadhopper

## Development

Firstly, `gem install bundler`, then:

    % git clone git://github.com/toolmantim/toadhopper.git
    % cd toadhopper
    % gem bundle
    % bin/rake test

If you set a `HOPTOAD_API_KEY` environment variable it'll test actually posting to the Hoptoad API. For example:

    % bin/rake test HOPTOAD_API_KEY=abc123

To generate the docs:

    % bin/yardoc

## Contributors

* [Tim Lucas](http://github.com/toolmantim)
* [Samuel Tesla](http://github.com/stesla)
* [atmos](http://github.com/atmos)
