##
# Root module
##
module DogWatch
  class << self
    # @param [Hash] args
    # @param [Proc] block
    # @return [DogWatch::Monitor]
    def monitor(*args, &block)
      DogWatch::Monitor.new(*args, &block)
    end
  end
end

require_relative 'dogwatch/version'
require_relative 'dogwatch/monitor'
require_relative 'dogwatch/dogfile'
