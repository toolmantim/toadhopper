require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class Toadhopper::TestNoticeDocument < Test::Unit::TestCase
  def test_filtering
    toadhopper.filters = "password"
    sensitive_options = {
      :params      => {"password" => "sensitive"},
      :session     => {"password" => "sensitive"},
      :environment => {"password" => "sensitive"}
    }
    notice_document = toadhopper.document_for(error, sensitive_options)
    assert_false notice_document.include?("sensitive")
  end
end
