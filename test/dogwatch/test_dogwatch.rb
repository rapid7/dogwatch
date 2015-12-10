require_relative '../test_helper'
require_relative '../../lib/dogwatch'

class TestDogWatch < Minitest::Test
  def test_dogwatch_returns_monitor
    IO.stub :read, "api_key: foo\napp_key: bar" do
      monitor = DogWatch.monitor do
        monitor 'foo' do
          #
        end
      end
      assert_instance_of(DogWatch::Monitor, monitor)
    end
  end
end
