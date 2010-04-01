require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class Toadhopper::TestFiltering < Test::Unit::TestCase
  def test_filtering
    assert_not_filtered "safe", "sensitive"
    assert_not_filtered "safe", /sensitive/
    assert_filtered "sensitive", "sensitive"
    assert_filtered "sensitive", /sensitive/
    assert_filtered "sensitive", /sit/
  end

  def assert_not_filtered(key, filter)
    assert_false filtered_document(key, "value", filter).include?(Toadhopper::FILTER_REPLACEMENT)
  end
  
  def assert_filtered(key, filter)
    assert_false filtered_document(key, "value", filter).include?("value")
  end

  def filtered_document(key, value, filter)
    toadhopper.filters = filter
    hash = {"nested" => {key => value}, key => value}
    toadhopper.__send__(:document_for, error, {:params => hash, :session => hash, :environment => hash})
  end
end
