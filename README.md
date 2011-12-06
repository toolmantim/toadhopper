A base library for [Airbrake](http://www.airbrakeapp.com/) error reporting.

Toadhopper can be used to report plain old Ruby exceptions, or to build a framework-specific gem such as [toadhopper-sinatra](http://github.com/toolmantim/toadhopper-sinatra).

    begin
      raise "Kaboom!"
    rescue  => e
      require 'toadhopper'
      Toadhopper("YOURAPIKEY").post!(e)
    end

You can install it via rubygems:

    gem install toadhopper

## SSL

Toadhopper can transport your messages over SSL.

In order to enable SSL, just add the `:secure` option.

    Toadhopper.new("YOURAPIKEY", :secure => true).post!(e)

Alternatively, you can specify a `:notify_host` with a https:// protocol.

    Toadhopper.new("YOURAPIKEY", :notify_host => 'https://airbrakeapp.com').post!(e)

_Note: You must have a paid plan for Airbrake to accept your messages over SSL._

## Deploy tracking

You can use Toadhopper to notify Airbrake of deployments:

    Toadhopper('YOURAPIKEY').deploy!
    
The method accepts options to set the environment, SCM revision, etc.

There is Capistrano support for deploy tracking. Simply require `toadhopper/capistrano` in your deploy config and set the variable `airbrake_api_key`:

    require 'toadhopper/capistrano'
    
    set :airbrake_api_key, 'YOURAPIKEY'

## Development

Install Bundler 0.9.x, then:

    % git clone git://github.com/toolmantim/toadhopper.git
    % cd toadhopper
    % bundle install
    % bundle exec rake test

If you set a `AIRBRAKE_API_KEY` environment variable it'll test actually posting to the Airbrake API. For example:

    % bundle exec rake test AIRBRAKE_API_KEY=abc123

Set SECURE=1 to test posting over SSL. For example:

    % bundle exec rake test AIRBRAKE_API_KEY=abc123 SECURE=1

_Note: You must have a paid plan for Airbrake to accept your messages over SSL._

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
* [Ben Klang](http://github.com/bklang)
