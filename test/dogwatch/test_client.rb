require_relative '../test_helper'
require_relative '../../lib/dogwatch/model/client'
require_relative '../../lib/dogwatch/model/config'
require_relative '../../lib/dogwatch/model/monitor'
require 'dogapi'
require 'json'

class TestClient < Minitest::Test
  TEST_RESPONSE = [
    '200',
    [
      name: 'test monitor',
      type: 'metric alert',
      query: 'test query'
    ]
  ].freeze

  UPDATED_RESPONSE = [
    '200',
    [
      name: 'Monitor name',
      type: :metric_alert,
      query: 'scheduled maintenance query'
    ]
  ].freeze

  def setup
    config = DogWatch::Model::Config.new('foo', 'bar')

    m = monitors
    k = Class.new(DogWatch::Model::Client) do
      define_method(:all_monitors) do
        m[1]
      end
    end
    @client = k.new(config)
  end

  def monitors
    monitor_file = File.expand_path('../../data/monitors.json', __FILE__)
    monitors = JSON.parse(IO.read(monitor_file))
    monitors
  end

  def test_create_monitor
    new_monitor = DogWatch::Model::Monitor.new('test monitor')
    new_monitor.type(:metric_alert)
    new_monitor.query('test query')

    @client.client.stub :monitor, TEST_RESPONSE do
      @client.execute(new_monitor)
      assert_equal @client.response.status, :created
    end
  end

  def test_update_monitor
    update_monitor = DogWatch::Model::Monitor.new('Monitor name')
    update_monitor.type(:metric_alert)
    update_monitor.query('scheduled maintenance query')

    @client.client.stub :update_monitor, UPDATED_RESPONSE do
      @client.execute(update_monitor)
      assert_equal @client.response.status, :updated
    end
  end
end
