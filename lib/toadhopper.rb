require 'net/http'
require 'yaml'

module Toadhopper
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
    def post!(error, options={}, header_options={})
      uri = URI.parse("http://hoptoadapp.com/notices/")
      Net::HTTP.start(uri.host, uri.port) do |http|
        headers = {
          'Content-type'             => 'application/x-yaml',
          'Accept'                   => 'text/xml, application/xml',
          'X-Hoptoad-Client-Name'    => 'Toadhopper',
        }.merge(header_options)
        http.read_timeout = 5 # seconds
        http.open_timeout = 2 # seconds
        begin
          http.post uri.path, {"notice" => notice_params(error, options)}.to_yaml, headers
        rescue TimeoutError => e
        end
       end
    end
    def notice_params(error, options={}) # :nodoc:
      clean_non_serializable_data(stringify_keys(
        {
          :api_key       => api_key,
          :error_class   => error.class.name,
          :error_message => error.message,
          :backtrace     => error.backtrace,
        }.merge(options)
      ))
    end
    def stringify_keys(hash) #:nodoc:
      hash.inject({}) do |h, pair|
        h[pair.first.to_s] = pair.last.is_a?(Hash) ? stringify_keys(pair.last) : pair.last
        h
      end
    end
    def serializable?(value) #:nodoc:
      value.is_a?(Fixnum) ||
      value.is_a?(Array) ||
      value.is_a?(String) ||
      value.is_a?(Hash) ||
      value.is_a?(Bignum)
    end
    def clean_non_serializable_data(data) #:nodoc:
      data.select{|k,v| serializable?(v) }.inject({}) do |h, pair|
        h[pair.first] = pair.last.is_a?(Hash) ? clean_non_serializable_data(pair.last) : pair.last
        h
      end
    end
  end
end