require_relative '../test_helper'
require_relative '../../lib/dogwatch/model/response'

class TestResponse < MiniTest::Test
  def setup
    @error_res = DogWatch::Model::Response.new(ERROR_RES, 'error')
    @valid_res = DogWatch::Model::Response.new(VALID_RES, 'foobar')
    @accepted_res = DogWatch::Model::Response.new(ACCEPTED_RES, 'foobar')
  end

  def test_status_is_error
    assert_equal :error, @error_res.status
  end

  def test_status_is_accepted
    assert_equal :accepted, @accepted_res.status
  end

  def test_status_message
    assert_equal ["The value provided for parameter 'query' is invalid"], \
                 @error_res.message
  end

  def test_message_output
    assert_equal 'Created monitor foobar with message foobar', @valid_res.message
  end

  def test_thor_output
    assert_equal [:created, 'Created monitor foobar with message foobar', :green],
                 @valid_res.to_thor
  end
end
