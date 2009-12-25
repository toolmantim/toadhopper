require File.dirname(__FILE__)+'/spec_helper'

class TestError < RuntimeError
end

describe 'Rack::Hoptoad' do
  let(:app)     { lambda { |env| raise TestError, 'Suffering Succotash!' } }
  let(:env)     { Rack::MockRequest.env_for("/foo?q=google", 'FOO' => 'BAR', :method => 'GET', :input => 'THE BODY') }
  let(:api_key) { ENV['MY_HOPTOAD_API_KEY'] }

  it 'allows for custom environmental variables to be excluded from hoptoad' do
    notifier = Rack::Hoptoad.new(app, 'pollywog') do |middleware|
      middleware.environment_filters << %w(MY_SECRET_STUFF MY_SECRET_KEY)
    end
    notifier.environment_filter_keys.should include('MY_SECRET_STUFF')
    notifier.environment_filter_keys.should include('MY_SECRET_KEY')
  end

  it 're-raises errors caught in the middleware' do
    notifier = Rack::Hoptoad.new(app, 'pollywog')
    lambda { notifier.call(env) }.should raise_error(TestError)
  end

  describe 'supports custom environments' do
    before { ENV['RACK_ENV'] = 'custom' }
    it 'works with a RACK_ENV of "custom"' do
      notifier =
        Rack::Hoptoad.new(app, api_key) do |middleware|
          middleware.report_under << 'custom'
          middleware.environment_filters << 'MY_HOPTOAD_API_KEY'
        end
      lambda { notifier.call(env) }.should raise_error(TestError)
      env['hoptoad.notified'].should eql(true)
    end
  end

  describe 'environmental variables other than RACK_ENV' do
    before { ENV['MERB_ENV'] = 'custom' }
    it 'works with MERB_ENV' do
      notifier =
        Rack::Hoptoad.new(app, api_key, 'MERB_ENV') do |middleware|
          middleware.report_under << 'custom'
          middleware.environment_filters << 'MY_HOPTOAD_API_KEY'
        end
      lambda { notifier.call(env) }.should raise_error(TestError)
      env['hoptoad.notified'].should eql(true)
    end
  end
end
