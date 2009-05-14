require File.dirname(__FILE__)+'/spec_helper'

class TestError < RuntimeError
end

def test_exception
  raise TestError, 'Suffering Succotash!'
rescue => boom
  return boom
end

describe 'Rack::HoptoadNotifier' do
  before(:each) do
    @app = lambda { |env| raise TestError, 'Why, I say' }
    @env = Rack::MockRequest.env_for("/foo?q=google",
      'FOO' => 'BAR',
      :method => 'GET',
      :input => 'THE BODY'
    )
  end

  it 'yields a configuration object to the block when created' do
    notifier = Rack::HoptoadNotifier.new(@app, 'pollywog') do |app|
      app.environment_filters << %w(MY_SECRET_STUFF MY_SECRET_KEY)
    end
    notifier.environment_filter_keys.should include('MY_SECRET_STUFF')
    notifier.environment_filter_keys.should include('MY_SECRET_KEY')
  end

  it 'catches exceptions raised from app, posts to hoptoad, and re-raises' do
    notifier = Rack::HoptoadNotifier.new(@app, 'pollywog')
    lambda { notifier.call(@env) }.should raise_error(TestError)
    @env['hoptoad.notified'].should eql(true)
  end

  if ENV['MY_HOPTOAD_INTEGRATION']
    it 'actually creates a hoptoad notifier in the app' do
      ENV['RACK_ENV'] = 'staging'
      notifier =
        Rack::HoptoadNotifier.new(@app, ENV['MY_HOPTOAD_INTEGRATION']) do |app|
          called = true
        end
      lambda { notifier.call(@env) }.should raise_error(TestError)
      @env['hoptoad.notified'].should eql(true)
    end
  end
end
