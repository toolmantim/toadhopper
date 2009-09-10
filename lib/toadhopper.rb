require 'net/http'
require 'yaml'
require 'timeout'

module Toadhopper
  class PostTimeoutError < StandardError; end
  class << self
    # Set the API key
    def api_key=(key)
      @@api_key = key
    end
    # Returns the key set by Toadhopper.api_key=
    def api_key
      @@api_key
    end
    # Sets patterns to [FILTER] out sensitive data such as passwords, emails and credit card numbers.
    #
    #   Toadhopper.filters = /password/, /email/, /credit_card_number/
    def filters=(*filters)
      @@filters = filters.flatten
    end
    # Returns the filters set by Toadhopper.filters=
    def filters
      [@@filters].flatten.compact
    end
    # Replaces the values of the keys matching Toadhopper.filters with [FILTERED]. Typically used on the params and environment hashes.
    def filter(hash)
      hash.inject({}) do |acc, (key, val)|
        acc[key] = filters.any? {|f| key.to_s =~ Regexp.new(f)} ? "[FILTERED]" : val
        acc
      end
    end
    # Posts an error to Hoptoad
    def post(error, request, environment, session)
      uri = URI.parse("http://hoptoadapp.com/notices/")
      Net::HTTP.start(uri.host, uri.port) do |http|
        headers = {'Content-type' => 'application/x-yaml', 'Accept' => 'text/xml, application/xml'}
        http.read_timeout = 5 # seconds
        http.open_timeout = 2 # seconds
        begin
           http.post(uri.path, notice_params(error, request, environment, session).to_yaml, headers)
        rescue Timeout::TimeoutError => e
          raise ToadHopper::PostTimeoutError
        end
       end
    end
    def notice_params(error, request, environment, session) # :nodoc:
      {
        :api_key       => api_key,
        :error_class   => error.class.name,
        :error_message => "#{error.class.name}: #{error.message}",
        :backtrace     => error.backtrace,
        :request       => request,
        :environment   => environment,
        :session       => session
      }
    end
  end
end