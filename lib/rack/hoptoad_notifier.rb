require 'net/http'

module Rack
  # Catches all exceptions raised from the app it wraps and
  # posts the results to hoptoad.
  class HoptoadNotifier
    attr_accessor :api_key, :environment_filters

    def initialize(app, api_key = nil)
      @app = app
      @api_key = api_key
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

  private
    def environment_filters
      @environment_filters ||= %w(AWS_ACCESS_KEY  AWS_SECRET_ACCESS_KEY AWS_ACCOUNT SSH_AUTH_SOCK)
    end

    def send_notification(exception, env)
      data = {
        :api_key       => api_key,
        :error_class   => exception.class.name,
        :error_message => "#{exception.class.name}: #{exception.message}",
        :backtrace     => exception.backtrace,
        :environment   => env.to_hash
      }

      bad_request = Rack::Request.new(env)

      data[:request] = {
        :params => {'request.path' => bad_request.path}.merge(bad_request.params)
      }

      data[:environment] = clean_hoptoad_environment(ENV.to_hash.merge(env))
      data[:environment][:RAILS_ENV] = ENV['RACK_ENV'] || 'development'

      data[:session] = {
         :key         => env['rack.session'] || 42,
         :data        => env['rack.session'] || { }
      }

      if %w(staging production).include?(ENV['RACK_ENV'])
        send_to_hoptoad :notice => default_notice_options.merge(data)
      end
      env['hoptoad.notified'] = true
    end

    def extract_body(env)
      if io = env['rack.input']
        io.rewind if io.respond_to?(:rewind)
        io.read
      end
    end

    def send_to_hoptoad(data) #:nodoc:
      url = URI.parse("http://hoptoadapp.com:80/notices/")

      Net::HTTP.start(url.host, url.port) do |http|
        headers = {
          'Content-type' => 'application/x-yaml',
          'Accept' => 'text/xml, application/xml'
        }
        http.read_timeout = 5 # seconds
        http.open_timeout = 2 # seconds
        # http.use_ssl = HoptoadNotifier.secure
        response = begin
                     http.post(url.path, clean_non_serializable_data(data).to_yaml, headers)
                   rescue TimeoutError => e
                     logger "Timeout while contacting the Hoptoad server."
                     nil
                   end
        case response
        when Net::HTTPSuccess then
          logger "Hoptoad Success: #{response.class}"
        else
          logger "Hoptoad Failure: #{response.class}\n#{response.body if response.respond_to? :body}"
        end
      end
    end

    def logger(str)
      puts str if ENV['RACK_DEBUG']
    end

    def default_notice_options #:nodoc:
      {
        :api_key       => api_key,
        :error_message => 'Notification',
        :backtrace     => nil,
        :request       => {},
        :session       => {},
        :environment   => {}
      }
    end

    def clean_non_serializable_data(notice) #:nodoc:
      notice.select{|k,v| serializable?(v) }.inject({}) do |h, pair|
        h[pair.first] = pair.last.is_a?(Hash) ? clean_non_serializable_data(pair.last) : pair.last
        h
      end
    end

    def serializable?(value) #:nodoc:
      value.is_a?(Fixnum) || 
      value.is_a?(Array)  || 
      value.is_a?(String) || 
      value.is_a?(Hash)   || 
      value.is_a?(Bignum)
    end

    def stringify_keys(hash) #:nodoc:
      hash.inject({}) do |h, pair|
        h[pair.first.to_s] = pair.last.is_a?(Hash) ? stringify_keys(pair.last) : pair.last
        h
      end
    end

    def clean_hoptoad_environment(environ) #:nodoc:
      environ.each do |k, v|
        environ[k] = "[FILTERED]" if environment_filters.any? do |filter|
          k.to_s.match(/#{filter}/)
        end
      end
    end
  end
end
