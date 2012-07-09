require 'net/https'
require 'erb'
require 'ostruct'
require 'toadhopper_exception'

# Posts errors to the Airbrake API
class Toadhopper
  VERSION             = '2.1'
  FILTER_REPLACEMENT  = "[FILTERED]"
  DEFAULT_DOMAIN      = 'airbrake.io'
  DEFAULT_NOTIFY_HOST = 'http://'+DEFAULT_DOMAIN
  # CA_FILE: Path to an updated certificate authority file, which was built from source
  # If you provide a custom Net :transport and get erroneous SSL peer verification failures,
  # try setting the transport's ca_file to Toadhopper::CA_FILE
  # @see https://github.com/toolmantim/toadhopper/blob/master/resources/README.md
  CA_FILE = File.expand_path File.join('..', 'resources', 'ca-bundle.crt'),
    File.dirname(__FILE__)

  # Airbrake API response
  class Response < Struct.new(:status, :body, :errors); end

  attr_reader :api_key, :error_url, :deploy_url

  # Initialize and configure a Toadhopper
  #
  # @param [String] Your api key
  # @param [Hash] params [optional]
  #
  #   :notify_host - [String] The default host to use
  #   :error_url   - [String] Absolute URL to use for error reporting
  #   :deploy_url  - [String] Absolute URL to use for deploy tracking
  #   :transport   - [Net::HTTP|Net::HTTP::Proxy] A customized Net::* object
  def initialize(api_key, params = {})
    @filters    = []
    @api_key    = api_key

    notify_host = URI.parse(params[:notify_host] || DEFAULT_NOTIFY_HOST)
    @transport  = params.delete :transport
    if @transport and not params[:notify_host]
      notify_host.scheme  = 'https' if @transport.use_ssl?
      notify_host.host    = @transport.address
      notify_host.port    = @transport.port
    end

    @error_url  = URI.parse(params.delete(:error_url)  || "#{notify_host}/notifier_api/v2/notices")
    @deploy_url = URI.parse(params.delete(:deploy_url) || "#{notify_host}/deploys.txt")

    validate!
  end

  def validate!
    validate_url! :error_url
    validate_url! :deploy_url
  end

  def validate_url!(sym)
    url = instance_variable_get '@'+sym.to_s
    unless url.absolute?
      raise ToadhopperException, "#{sym} #{url.inspect} must begin with http:// or https://"
    end

    if @transport
      if @transport.use_ssl? != url.scheme.eql?('https')
        raise ToadhopperException,
          ":transport use_ssl? setting of #{@transport.use_ssl?.inspect} does not match" +
          " #{sym} scheme #{url.scheme.inspect}"
      elsif @transport.address != url.host
        raise ToadhopperException,
          ":transport hostname #{@transport.address.inspect} does not match" +
          " #{sym} hostname #{url.host.inspect}"
      elsif @transport.port != url.port
        raise ToadhopperException,
          ":transport port #{@transport.port.inspect} does not match" +
          " #{sym} port #{url.port.inspect}"
      end
    end
  end

  # Sets patterns to +[FILTER]+ out sensitive data such as +/password/+, +/email/+ and +/credit_card_number/+
  def filters=(*filters)
    @filters = filters.flatten
  end

  # Posts an exception to Airbrake.
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
  #                              {'X-Airbrake-Client-Name' => 'My Awesome Notifier'}
  #
  # @return [Response]
  def post!(error, options={}, http_headers={})
    options[:notifier_name] ||= 'Toadhopper'
    post_document(document_for(error, options), {'X-Airbrake-Client-Name' => options[:notifier_name]})
  end

  # Posts a deployment notification
  #
  # @param [Hash] options
  # @option options [String] framework_env  The framework environment your app is running under, defaults to development
  # @option options [String] scm_repository The repository URL
  # @option options [String] scm_revision   The current repository revision
  # @option options [String] username       Your name, defaults to `whoami`
  #
  # @return [Response]
  def deploy!(options={})
    params = {}
    params['api_key'] = @api_key
    params['deploy[rails_env]'] = options[:framework_env] || 'development'
    params['deploy[local_username]'] = options[:username] || %x(whoami).strip
    params['deploy[scm_repository]'] = options[:scm_repository]
    params['deploy[scm_revision]'] = options[:scm_revision]
    response(@deploy_url, params)
  end

  def secure?
    connection(@deploy_url).use_ssl? and connection(@error_url).use_ssl?
  end

  # Provider of the net transport used
  #
  # MIT Licensing Note: Portions of logic below for connecting via SSL were
  # copied from the airbrake project under the MIT License.
  #
  # @see https://github.com/airbrake/airbrake/blob/master/MIT-LICENSE
  def connection(uri)
    return @transport if @transport

    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 5 # seconds
    http.open_timeout = 2 # seconds
    if uri.scheme.eql? 'https'
      http.use_ssl      = true
      http.ca_file      = CA_FILE
      http.verify_mode  = OpenSSL::SSL::VERIFY_PEER
    end
    http
  end

  private

  def document_defaults(error)
    {
      :error            => error,
      :api_key          => api_key,
      :environment      => ENV.to_hash,
      :backtrace        => backtrace_for(error),
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

  def filters
    [@filters].flatten.compact
  end

  def post_document(document, headers={})
    all_headers = {'Content-type' => 'text/xml', 'Accept' => 'text/xml, application/xml'}.merge(headers)
    response(@error_url, document, all_headers)
  end

  def response(uri, data, headers=nil)
    connection(uri).start do |http|
      begin
        # If data is Hash-like, we post it as a form
        response = if data.respond_to? :has_key?
          # Post url-encoded form data
          request = Net::HTTP::Post.new(uri.path)
          request.form_data = data
          http.request(request)
        else
          # Post a basic body of data
          http.post uri.path, data, headers
        end
        parse_response(response)
      rescue TimeoutError => e
        Response.new(500, '', ['Timeout error'])
      end
    end
  end

  def parse_response(response)
    if response.body.include? '</'
      parse_xml_response(response)
    else
      parse_text_response(response)
    end
  end

  def parse_xml_response(response)
    Response.new(response.code.to_i,
                 response.body,
                 response.body.scan(%r{<error>(.+)<\/error>}).flatten)
  end

  def parse_text_response(response)
    errors = []
    unless response.kind_of? Net::HTTPSuccess or response.body.to_s.empty?
      errors << response.body
    end
    Response.new(response.code.to_i, response.body, errors)
  end

  def document_for(exception, options={})
    data = document_data(exception, options)
    scope = OpenStruct.new(data).extend(ERB::Util)
    scope.instance_eval ERB.new(notice_template, nil, '-').src
  end

  BacktraceLine = Struct.new(:file, :number, :method)

  def backtrace_for(error)
    lines = Array(error.backtrace).map {|l| backtrace_line(l)}
    if lines.empty?
      lines << BacktraceLine.new("no-backtrace", "1", nil)
    end
    lines
  end

  def backtrace_line(line)
    if match = line.match(%r{^(.+):(\d+)(?::in `([^']+)')?$})
      BacktraceLine.new(*match.captures)
    else
      BacktraceLine.new(line, "1", nil)
    end
  end

  def notice_template
    File.read(::File.join(::File.dirname(__FILE__), 'notice.erb'))
  end

  def clean(hash)
    hash.inject({}) do |acc, (k, v)|
      acc[k] = (v.is_a?(Hash) ? clean(v) : filtered_value(k,v))
      acc
    end
  end

  def filtered_value(key, value)
    if filters.any? {|f| key.to_s =~ Regexp.new(f)}
      FILTER_REPLACEMENT
    else
      value.to_s
    end
  end
end

# Convenience method for creating Toadhoppers
#
# @return [Toadhopper]
def Toadhopper(api_key)
  Toadhopper.new(api_key)
end
