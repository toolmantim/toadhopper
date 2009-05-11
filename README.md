rack_hoptoad
============

A gem that provides exception notifications to [hoptoad](http://hoptoadapp.com) as rack middleware.

Usage
=====
Throw something like this in your config.ru to enable notifications.

    require 'rack_hoptoad'

    ENV['RACK_ENV'] = 'production'

    use Rack::HoptoadNotifier, 'fd48c7d26f724503a0280f808f44b339fc65fab8'

If your RACK_ENV variable is set to production it'll actually post to hoptoad.
It won't process in the other environments.

Installation
============

    % sudo gem install rack_hoptoad
