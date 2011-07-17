A base library for [Airbrake](http://airbrakeapp.com) (formerly [Hoptoad](http://robots.thoughtbot.com/post/7665411707/hoptoad-is-now-airbrake)) error reporting.

Toadhopper can be used to report plain old Ruby exceptions, or to build a framework-specific gem such as [toadhopper-sinatra](http://github.com/toolmantim/toadhopper-sinatra).

    begin
      raise "Kaboom!"
    rescue  => e
      require 'toadhopper'
      Toadhopper("YOURAPIKEY").post!(e)
    end

You can install it via rubygems:

    gem install toadhopper

## Deploy tracking

You can use Toadhopper to notify Hoptoad of deployments:

    Toadhopper('YOURAPIKEY').deploy!
    
The method accepts options to set the environment, SCM revision, etc.

There is Capistrano support for deploy tracking. Simply require `toadhopper/capistrano` in your deploy config and set the variable `hoptoad_api_key`:

    require 'toadhopper/capistrano'
    
    set :hoptoad_api_key, 'YOURAPIKEY'

## Development

Install Bundler 0.9.x, then:

    % git clone git://github.com/toolmantim/toadhopper.git
    % cd toadhopper
    % bundle install
    % bundle exec rake test

If you set a `HOPTOAD_API_KEY` environment variable it'll test actually posting to the Hoptoad API. For example:

    % bundle exec rake test HOPTOAD_API_KEY=abc123

To generate the docs:

    % bundle exec yardoc

To build the gem:

    % bundle exec rake build

## Contributors

* [Tim Lucas](http://github.com/toolmantim)
* [Samuel Tesla](http://github.com/stesla)
* [Corey Donohoe](http://github.com/atmos)
* [Andre Arko](http://github.com/indirect)
* [Loren Segal](http://github.com/lsegal)
* [Theo Hultberg](http://github.com/iconara)