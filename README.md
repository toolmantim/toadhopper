[![Build Status](https://secure.travis-ci.org/toolmantim/toadhopper.png)](http://travis-ci.org/toolmantim/toadhopper)

A base library for [Airbrake](http://www.airbrake.io/) error reporting.

Toadhopper can be used to report plain old Ruby exceptions, or to build a framework-specific gem such as [toadhopper-sinatra](http://github.com/toolmantim/toadhopper-sinatra).

    begin
      raise "Kaboom!"
    rescue  => e
      require 'toadhopper'
      Toadhopper("YOURAPIKEY").post!(e)
    end

You can install it via rubygems:

    gem install toadhopper

## Posting Notices Over SSL

Toadhopper can transport your messages over SSL.

In order to enable SSL, you can specify a `:notify_host` with a https:// protocol.

    Toadhopper.new("YOURAPIKEY", :notify_host => 'https://airbrake.io').post!(e)

_Note: You must have a paid plan for Airbrake to accept your messages over SSL._

## Deploy tracking

You can use Toadhopper to notify Airbrake of deployments:

    Toadhopper('YOURAPIKEY').deploy!
    
The method accepts options to set the environment, SCM revision, etc.

There is Capistrano support for deploy tracking. Simply require `toadhopper/capistrano` in your deploy config and set the variable `airbrake_api_key`:

    require 'toadhopper/capistrano'
    
    set :airbrake_api_key, 'YOURAPIKEY'

## Compatibility

Toadhopper is tested against and compatible with the following ruby platforms:

  * **1.8.7**
  * **1.9.2**
  * **1.9.3**
  * **ree 1.8.7-2011.03**
  * **jruby 1.6.3**

    For jruby support, you need to `gem install jruby-openssl` if you do not already have that gem.
    [More info on why this is.](http://blog.mattwynne.net/2011/04/26/targeting-multiple-platforms-jruby-etc-with-a-rubygems-gemspec/)

  * **rubinius 2.0.testing** branch in ruby 1.8 mode (1.9 mode is not supported)

## Development

Install Bundler 0.9.x, then:

    % git clone git://github.com/toolmantim/toadhopper.git
    % cd toadhopper
    % bundle install
    % bundle exec rake test

If you set a `AIRBRAKE_API_KEY` environment variable it'll test actually posting to the Airbrake API. For example:

    % bundle exec rake test AIRBRAKE_API_KEY=abc123

Set `AIRBRAKE_FULL_TEST` to test integration operations that require a paid Airbrake plan such as posting over SSL, deploy tracking, and github integration.  For example:

    % bundle exec rake test AIRBRAKE_API_KEY=abc123 AIRBRAKE_FULL_TEST=1

_Beware: Setting `AIRBRAKE_FULL_TEST` will record a bogus deployment in your Airbrake project and auto-resolve any pre-existing development errors._

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
* [Stephen George](https://github.com/sfgeorge)
