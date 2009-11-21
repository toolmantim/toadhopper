require 'net/http'

module Rack
  # Catches all exceptions raised from the app it wraps and
  # posts the results to hoptoad.
  class HoptoadNotifier
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

    def notice_template
      ::File.read(::File.join(::File.dirname(__FILE__), 'notice.xml.erb'))
    end

    INPUT_FORMAT = %r{^([^:]+):(\d+)(?::in `([^']+)')?$}.freeze

    class Backtrace < Struct.new(:file, :number, :method); end
    def build_backtrace(exception)
      exception.backtrace.map do |line|
        _, file, number, method = line.match(INPUT_FORMAT).to_a
        Backtrace.new(file, number, method)
      end
    end

    def send_notification(exception, env)
      @error        = exception
      @api_key      = api_key
      @request      = Rack::Request.new(env)
      @request_path = @request.script_name + @request.path_info
      @environment  = clean_hoptoad_environment(ENV.to_hash.merge(env))
      @backtrace    = build_backtrace(exception)

      document = ERB.new(notice_template).result(binding)

      if %w(staging production).include?(ENV['RACK_ENV'])
        send_to_hoptoad document
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
      url = URI.parse("http://hoptoadapp.com:80/notifier_api/v2/notices")

      Net::HTTP.start(url.host, url.port) do |http|
        headers = {
          'Content-type' => 'text/xml',
          'Accept'       => 'text/xml, application/xml'
        }

        http.read_timeout = 5 # seconds
        http.open_timeout = 2 # seconds
        # http.use_ssl = HoptoadNotifier.secure
        response = begin
                     http.post(url.path, data, headers)
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

    def clean_non_serializable_data(notice) #:nodoc:
      notice.select{|k,v| serializable?(v) }.inject({}) do |h, pair|
        h[pair.first] = pair.last.is_a?(Hash) ? clean_non_serializable_data(pair.last) : pair.last
        h
      end
    end

    def clean_hoptoad_environment(environment) #:nodoc:
      clean_non_serializable_data(environment).each do |key, value|
        environment[key] = "[FILTERED]" if filter?(key)
      end
    end

    def filter?(key)
      environment_filter_keys.any? do |filter|
        key.to_s.match(/#{filter}/)
      end
    end

    def serializable?(value) #:nodoc:
      value.is_a?(Fixnum) ||
      value.is_a?(Array)  ||
      value.is_a?(String) ||
      value.is_a?(Hash)   ||
      value.is_a?(Bignum)
    end
  end
end
