require 'net/http'
require 'erb'
require 'ostruct'

# Posts errors to the Hoptoad API
class Toadhopper
  VERSION = "0.9.8"

  # Hoptoad API response
  class Response < Struct.new(:status, :body, :errors); end

  attr_reader :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  # Sets patterns to +[FILTER]+ out sensitive data such as +/password/+, +/email/+ and +/credit_card_number/+
  def filters=(*filters)
    @filters = filters.flatten
  end

  # @private
  def filters
    [@filters].flatten.compact
  end

  # Posts an exception to hoptoad.
  #
  # @param [Exception] error the error to post
  #
  # @param [Hash] options
  # @option options [String]  url              The url for the request, required to post but not useful in a console environment
  # @option options [String]  component        Normally this is your Controller name in an MVC framework
  # @option options [String]  action           Normally the action for your request in an MVC framework
  # @option options [Hash]    params           A hash of the request's parameters
  # @option options [String]  notifier_name    Say you're a different notifier than Toadhopper
  # @option options [String]  notifier_version Specify the version of your custom notifier
  # @option options [String]  notifier_url     Specify the project URL of your custom notifier
  # @option options [Hash]    session          A hash of the user session in a web request
  # @option options [String]  framework_env    The framework environment your app is running under
  # @option options [Array]   backtrace        Normally not needed, parsed automatically from the provided exception parameter
  # @option options [Hash]    environment      You MUST scrub your environment if you plan to use this, please do not use it though. :)
  # @option options [String]  project_root     The root directory of your app
  #
  # @param [Hash] http_headers extra HTTP headers to be sent in the post to the API
  #
  # @example
  #   Toadhopper('apikey').post! error,
  #                              {:action => 'show', :controller => 'Users'},
  #                              {'X-Hoptoad-Client-Name' => 'My Awesome Notifier'}
  #
  # @return [Response]
  def post!(error, options={}, http_headers={})
    options[:notifier_name] ||= 'Toadhopper'
    post_document(document_for(error, options), {'X-Hoptoad-Client-Name' => options[:notifier_name]})
  end

  # @private
  def post_document(document, headers={})
    uri = URI.parse("http://hoptoadapp.com:80/notifier_api/v2/notices")
    Net::HTTP.start(uri.host, uri.port) do |http|
      http.read_timeout = 5 # seconds
      http.open_timeout = 2 # seconds
      begin
        response = http.post uri.path,
                             document,
                             {'Content-type' => 'text/xml', 'Accept' => 'text/xml, application/xml'}.merge(headers)
        Response.new response.code.to_i,
                     response.body,
                     response.body.scan(%r{<error>(.+)<\/error>}).flatten
      rescue TimeoutError => e
        Response.new(500, '', ['Timeout error'])
      end
    end
  end

  # @private
  def document_for(exception, options={})
    data = document_data(exception, options)
    scope = OpenStruct.new(data).extend(ERB::Util)
    ERB.new(notice_template, nil, '-').result(scope.send(:binding))
  end

  def document_defaults(error)
    {
      :error            => error,
      :api_key          => api_key,
      :environment      => ENV.to_hash,
      :backtrace        => error.backtrace.map {|l| backtrace_line(l)},
      :url              => 'http://localhost/',
      :component        => 'http://localhost/',
      :action           => nil,
      :request          => nil,
      :params           => nil,
      :notifier_version => VERSION,
      :notifier_url     => 'http://github.com/toolmantim/toadhopper',
      :session          => {},
      :framework_env    => ENV['RACK_ENV'] || 'development',
      :project_root     => Dir.pwd
    }
  end

  def document_data(error, options)
    data = document_defaults(error).merge(options)
    [:params, :session, :environment].each{|n| data[n] = clean(data[n]) if data[n] }
    data
  end

  # @private
  def backtrace_line(line)
    Struct.new(:file, :number, :method).new(*line.match(%r{^([^:]+):(\d+)(?::in `([^']+)')?$}).captures)
  end

  # @private
  def notice_template
    File.read(::File.join(::File.dirname(__FILE__), 'notice.erb'))
  end

  # @private
  def clean(hash)
    hash.inject({}) do |acc, (k, v)|
      acc[k] = (v.is_a?(Hash) ? clean(v) : filtered_value(k,v)) if serializable?(v)
      acc
    end
  end

  # @private
  def filtered_value(key, value)
    if filters.any? {|f| key.to_s =~ Regexp.new(f)}
      "[FILTERED]"
    else
      value
    end
  end

  # @private
  def serializable?(value)
    [Fixnum, Array, String, Hash, Bignum].any? {|c| value.is_a?(c)}
  end
end

# Convenience method for creating Toadhoppers
#
# @return [Toadhopper]
def Toadhopper(api_key)
  Toadhopper.new(api_key)
end
