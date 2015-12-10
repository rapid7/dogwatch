require_relative '../test_helper'
require_relative '../../lib/dogwatch/model/mixin/colorize'

class ToColor
  extend DogWatch::Model::Mixin::Colorize

  colorize(:action,
           :green => [:created, :accepted, :updated],
           :yellow => [],
           :red => [:error])
end

class TestColorize < Minitest::Test
  def setup
    @tocolor = ToColor.new
  end

  def test_colorize_default
    assert_equal :green, @tocolor.color
  end
end
