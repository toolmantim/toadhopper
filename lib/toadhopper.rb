root = File.expand_path(File.dirname(__FILE__))
require 'net/http'
require 'haml'
require 'haml/engine'
require 'nokogiri'
require File.join(root, 'backtrace')

module ToadHopper
  class Response < Struct.new(:status, :body, :errors); end

  class Dispatcher
    attr_accessor :api_key
    def self.backtrace_for(exception)
      Backtrace.from_exception(exception)
    end

    def initialize(api_key=nil)
      self.api_key = api_key
    end
    # Sets patterns to [FILTER] out sensitive data such as passwords, emails and credit card numbers.
    #
    #   Toadhopper.filters = /password/, /email/, /credit_card_number/
    def filters=(*filters)
      @filters = filters.flatten
    end
    # Returns the filters
    def filters
      [@filters].flatten.compact
    end

    def post!(error, header_options = { })
      post_document(document_for(error), header_options)
    end

    # Posts a v2 document error to Hoptoad
    def post_document(document, header_options = { })
      uri = URI.parse("http://hoptoadapp.com:80/notifier_api/v2/notices")

      Net::HTTP.start(uri.host, uri.port) do |http|
        headers = {
          'Content-type'             => 'text/xml',
          'Accept'                   => 'text/xml, application/xml',
          'X-Hoptoad-Client-Name'    => 'Toadhopper',
        }.merge(header_options)
        http.read_timeout = 5 # seconds
        http.open_timeout = 2 # seconds
        begin
          response = http.post uri.path, document, headers
          response_for(response)
        rescue TimeoutError => e
          Response.new(500, '', ['Timeout error'])
        end
      end
    end

    def response_for(response)
      status = Integer(response.code)
      case status
      when 422
        errors = Nokogiri::XML.parse(response.body).xpath('//errors/error')
        Response.new(status, response.body, errors.map { |error| error.content })
      else
        Response.new(status, response.body, [ ])
      end
    end

    # Replaces the values of the keys matching Toadhopper.filters with
    # [FILTERED]. Typically used on the params and environment hashes.
    def filter(hash)
      hash.inject({}) do |acc, (key, val)|
        acc[key] = filter?(key) ? "[FILTERED]" : val
        acc
      end
    end

    private
      def document_for(exception)
        locals = { :error         => exception,
          :api_key       => api_key,
          :environment   => scrub_environment(ENV.to_hash),
          :backtrace     => Backtrace.from_exception(exception), 
          :framework_env => ENV['RACK_ENV'] || 'development' }
        Haml::Engine.new(notice_template).render(Object.new, locals)
      end

      def filter?(key)
        filters.any? do |filter|
          key.to_s =~ Regexp.new(filter)
        end
      end

      def scrub_environment(hash)
        filter(clean_non_serializable_data(hash))
      end

      def clean_non_serializable_data(data) #:nodoc:
        data.select{|k,v| serializable?(v) }.inject({}) do |h, pair|
          h[pair.first] = pair.last.is_a?(Hash) ? clean_non_serializable_data(pair.last) : pair.last
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

      def notice_template
        ::File.read(::File.join(::File.dirname(__FILE__), 'notice.haml'))
      end
    end
end
