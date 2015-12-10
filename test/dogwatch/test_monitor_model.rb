require_relative '../test_helper'
require_relative '../../lib/dogwatch/model/monitor'

class TestMonitorModel < Minitest::Test
  def setup
    @monitor = DogWatch::Model::Monitor.new('foobar')
    @monitor.type(:service_check)
    @monitor.query('quiz baz')
  end

  def test_type
    assert_equal 'service check', @monitor.attributes.type
    assert_kind_of String, @monitor.attributes.type
  end

  def test_query
    assert_equal 'quiz baz', @monitor.attributes.query
    assert_kind_of String, @monitor.attributes.query
  end

  def test_message
    @monitor.message('The quick brown fox')
    assert_equal 'The quick brown fox', @monitor.attributes.message
    assert_kind_of String, @monitor.attributes.message
  end

  def test_tags
    @monitor.tags([1, 2, 3])
    assert_equal [1, 2, 3], @monitor.attributes.tags
    assert_kind_of Array, @monitor.attributes.tags
  end

  def test_options
    @monitor.options do
      notify_no_data false
      no_data_timeframe 3
    end
    expected = {
      notify_no_data: false,
      no_data_timeframe: 3
    }

    assert_equal expected, @monitor.attributes.options
    assert_kind_of Hash, @monitor.attributes.options
  end

  def test_validate
    assert_equal true, @monitor.validate

    @monitor.attributes.query = nil
    assert_equal false, @monitor.validate
  end
end
