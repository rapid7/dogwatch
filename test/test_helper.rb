require 'simplecov'
SimpleCov.start do
  add_filter '/.bundle/'
end

require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../lib/dogwatch'
require_relative 'data/responses'

MiniTest::Reporters.use!

module Minitest
  module Assertions
    def assert_nothing_raised(*)
      yield
    end
  end
end
