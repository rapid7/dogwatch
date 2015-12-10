require 'yaml'
require_relative '../test_helper'
require_relative '../../lib/dogwatch/model/config'

class TestConfig < Minitest::Test
  def setup
    creds = "api_key: foo\napp_key: bar"

    IO.stub :read, creds do
      @fromfile = DogWatch::Model::Config.new
    end
  end

  def test_valid_creds
    assert_equal 'foo', @fromfile.api_key
    assert_equal 'bar', @fromfile.app_key
  end

  def test_creds_provided_in_initialize
    config = DogWatch::Model::Config.new('foo', 'bar')
    assert_equal 'foo', config.api_key
    assert_equal 'bar', config.app_key
  end

  def test_no_creds_provided
    Dir.stub :home, '/dev/null' do
      err = assert_raises(RuntimeError) { DogWatch::Model::Config.new }
      assert_equal 'No credentials supplied', err.message
    end
  end
end
