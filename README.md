rack_hoptoad
============

A gem that provides exception notifications to [hoptoad](http://hoptoadapp.com) as rack middleware.

Usage
=====
Throw something like this in your config.ru to enable notifications.

    require 'rack/hoptoad'

    use Rack::Hoptoad, 'fd48c7d26f724503a0280f808f44b339fc65fab8'

You can also exclude certain sensitive environmental variables using the block syntax

    use Rack::Hoptoad, 'fd48c7d26f724503a0280f808f44b339fc65fab8' do |notifier|
      notifier.environment_filters << %w(MY_SECRET_KEY MY_SECRET_TOKEN)
    end

If you want to post exceptions in an environment other than staging or production(the defaults)

    use Rack::Hoptoad, 'fd48c7d26f724503a0280f808f44b339fc65fab8' do |notifier|
      notifier.report_under << 'custom'
    end

If you want to use an environmental variable other than RACK_ENV and still have it post

    use Rack::Hoptoad, 'fd48c7d26f724503a0280f808f44b339fc65fab8', 'MERB_ENV' do |notifier|
      notifier.report_under        << 'custom'
      notifier.environment_filters << %w(MY_SECRET_KEY MY_SECRET_TOKEN)
    end

Installation
============

    % sudo gem install rack_hoptoad

Sinatra Notes
=============

In order for exceptions to propagate up to Rack in Sinatra you need to enable raise_errors

    class MyApp < Sinatra::Default
      enable :raise_errors
    end

Note that the errors block does not execute so you'll need to handle the 500 elsewhere.  Normally this is done with a 500.html in the document root.
