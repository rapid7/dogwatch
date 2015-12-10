##
# Root module
##
module DogWatch
  class << self
    def monitor(*args, &block)
      DogWatch::Monitor.new(*args, &block)
    end
  end
end

require_relative 'dogwatch/version'
require_relative 'dogwatch/monitor'
