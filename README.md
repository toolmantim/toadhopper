rack_hoptoad
============

A gem that provides exception notifications to [hoptoad](http://hoptoadapp.com) as rack middleware.

Usage
=====
Throw something like this in your config.ru to enable notifications.

    require 'rack_hoptoad'

    use Rack::HoptoadNotifier, 'fd48c7d26f724503a0280f808f44b339fc65fab8'

You can also exclude certain sensitive environmental variables using the block syntax

    require 'rack_hoptoad'

    use Rack::HoptoadNotifier, 'fd48c7d26f724503a0280f808f44b339fc65fab8' do |notifier|
      notifier.environment_filters << %w(MY_SECRET_KEY MY_SECRET_TOKEN)
    end


If your RACK_ENV variable is set to production or staging it'll actually post
to hoptoad.  It won't process in the other environments.

Installation
============

    % sudo gem install rack_hoptoad
