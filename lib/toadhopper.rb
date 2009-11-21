root = File.expand_path(File.dirname(__FILE__))
require 'net/http'
require 'haml'
require 'haml/engine'
require File.join(root, 'backtrace')

class Toadhopper
  def self.instance
    @instance ||= new
  end
  def self.method_missing(name, *args)
    instance.send(name, *args)
  end

  def initialize(api_key=nil)
    self.api_key = api_key
  end
  # Set the API key
  def api_key=(key)
    @api_key = key
  end
  # Returns the API key
  def api_key
    @api_key
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

  def notice_template
    ::File.read(::File.join(::File.dirname(__FILE__), 'notice.haml'))
  end

  def document_for(exception)
    locals = { :error         => exception,
               :api_key       => api_key,
               :environment   => clean_non_serializable_data(ENV.to_hash),
               :backtrace     => Backtrace.from_exception(exception), 
               :framework_env => ENV['RACK_ENV'] || 'development' }
    Haml::Engine.new(notice_template).render(Object.new, locals)
  end

  # Posts an error to Hoptoad
  def post!(error, options={}, header_options={})
    uri = URI.parse("http://hoptoadapp.com:80/notifier_api/v2/notices")
    document = document_for(error)

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
        response.code == 200
      rescue TimeoutError => e
        false
      end
     end
  end
    # Replaces the values of the keys matching Toadhopper.filters with [FILTERED]. Typically used on the params and environment hashes.
    def filter(hash)
      hash.inject({}) do |acc, (key, val)|
        acc[key] = filters.any? {|f| key.to_s =~ Regexp.new(f)} ? "[FILTERED]" : val
        acc
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
    private
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

# Instanties a Toadhopper with the given api_key
def Toadhopper(api_key)
  Toadhopper.new(api_key)
end
