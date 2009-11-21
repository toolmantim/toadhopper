require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class Toadhopper::TestNoticeParams < Test::Unit::TestCase
  def test_notice_params
    Toadhopper.api_key = "abc123"
    error = begin; raise "Kaboom!"; rescue => e; e end
    def error.backtrace; ["backtrace line 1", "backtrace line 2"] end
    assert_equal({
      "api_key"       => "abc123",
      "error_class"   => "RuntimeError",
      "error_message" => "Kaboom!",
      "backtrace"     => ["backtrace line 1", "backtrace line 2"],
      "request"       => {"request_var" => "request_val"},
      "environment"   => {"env_var" => "env_val"},
      "session"       => {"session_var" => "session_val"},
      },
      Toadhopper.notice_params(
        error,
        {
          "request" => {"request_var" => "request_val"},
          "environment" => {"env_var" => "env_val"},
          "session" => {"session_var" => "session_val"}
        }
      )
    )
  end
end
