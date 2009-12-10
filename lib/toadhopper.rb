root = File.expand_path(File.dirname(__FILE__))
require 'net/http'
require 'haml'
require 'haml/engine'
require 'nokogiri'
require File.join(root, 'backtrace')

module ToadHopper
  # A class for handling hoptoad responses without exposing the transport layer
  class Response < Struct.new(:status, :body, :errors); end

  # A class to Dispatch errors to a Hoptoad Project, many instances can be created
  class Dispatcher
    attr_accessor :api_key

    def initialize(api_key=nil)
      self.api_key = api_key
    end
    # Sets patterns to [FILTER] out sensitive data such as passwords, emails and credit card numbers.
    #
    #   Toadhopper::Dispatcher.new('apikey').filters = /password/, /email/, /credit_card_number/
    def filters=(*filters)
      @filters = filters.flatten
    end

    # Returns the filters for the Dispatcher
    def filters
      [@filters].flatten.compact
    end

    # Post a v2 exception to hoptoad allowing for document options ot be overridden by library users
    #   Toadhopper::Dispatcher.new('apikey').post!(exception, {:action => 'show', :controller => 'Users'})
    # The Following Keys are available as parameters to the document_options
    #   error            The actual exception to be reported
    #   api_key          The api key for your project
    #   url              The url for the request, required to post but not useful in a console environment
    #   component        Normally this is your Controller name in an MVC framework
    #   action           Normally the action for your request in an MVC framework
    #   request          An object that response to #params and returns a hash
    #   notifier_name    Say you're a different notifier than ToadHopper
    #   notifier_version Specify the version of your custom notifier
    #   session          A hash of the user session in a web request
    #   framework_env    The framework environment your app is running under
    #   backtrace        Normally not needed, parsed automatically from the provided exception parameter
    #   environment      You MUST scrub your environment if you plan to use this, please do not use it though. :)
    def post!(error, document_options = { }, header_options = { })
      post_document(document_for(error, document_options), header_options)
    end

    # Posts a v2 document error to Hoptoad
    # header_options can be passed in to indicate you're posting from a separate client
    #   Toadhopper::Dispatcher.new('API KEY').post_document(doc, 'X-Hoptoad-Client-Name' => 'MyCustomDispatcher')
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

    def filter(hash)
      hash.inject({}) do |acc, (key, val)|
        acc[key] = filter?(key) ? "[FILTERED]" : val
      acc
      end
    end

    private
      # Replaces the values of the keys matching Toadhopper.filters with
      # [FILTERED]. Typically used on the params and environment hashes.

      def document_for(exception, options = { }) #:nodoc:
        locals = {
          :error            => exception,
          :api_key          => api_key,
          :environment      => scrub_environment(ENV.to_hash),
          :backtrace        => Backtrace.from_exception(exception),
          :url              => 'http://localhost/',
          :component        => 'http://localhost/',
          :action           => nil,
          :request          => nil,
          :notifier_name    => 'ToadHopper',
          :notifier_version => '0.8',
          :session          => { },
          :framework_env    => ENV['RACK_ENV'] || 'development' }.merge(options)

        Haml::Engine.new(notice_template).render(Object.new, locals)
      end

      def response_for(response) #:nodoc:
        status = Integer(response.code)
        case status
        when 422
          errors = Nokogiri::XML.parse(response.body).xpath('//errors/error')
          Response.new(status, response.body, errors.map { |error| error.content })
        else
          Response.new(status, response.body, [ ])
        end
      end

      def filter?(key) #:nodoc:
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

      def notice_template #:nodoc:
        ::File.read(::File.join(::File.dirname(__FILE__), 'notice.haml'))
      end
    end
end
