require 'rack'
require 'erb'
require 'toadhopper'

module Rack
  # Catches all exceptions raised from the app it wraps and
  # posts the results to hoptoad.
  class Hoptoad
    attr_accessor :api_key, :environment_filters

    def initialize(app, api_key = nil)
      @app = app
      @api_key = api_key
      @environment_filters = %w(AWS_ACCESS_KEY  AWS_SECRET_ACCESS_KEY AWS_ACCOUNT SSH_AUTH_SOCK)
      yield self if block_given?
    end

    def call(env)
      status, headers, body =
        begin
          @app.call(env)
        rescue StandardError, LoadError, SyntaxError => boom
          # TODO don't allow exceptions from send_notification to
          # propogate
          send_notification boom, env 
          raise
        end
      send_notification env['rack.exception'], env if env['rack.exception']
      [status, headers, body]
    end

    def environment_filter_keys
      @environment_filters.flatten
    end
  private

    def send_notification(exception, env)
      request      = Rack::Request.new(env)

      options = {
        :api_key           => api_key,
        :url               => "#{request.scheme}://#{request.host}#{request.path}",
        :request           => request,
        :framework_env     => ENV['RACK_ENV'] || 'development',
        :notifier_name     => 'Rack::Hoptoad',
        :notifier_version  => '0.0.6',
        :session           => env['rack.session']
      }

      if %w(staging production).include?(ENV['RACK_ENV'])
        ToadHopper.new(api_key).post!(exception, options, {'X-Hoptoad-Client-Name' => 'Rack::Hoptoad'})
      end
      env['hoptoad.notified'] = true
    end

    def extract_body(env)
      if io = env['rack.input']
        io.rewind if io.respond_to?(:rewind)
        io.read
      end
    end
  end
end
