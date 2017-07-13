require_relative 'model/config'
require_relative 'model/client'

module DogWatch
  ##
  # Manage the execution of the Dogfile
  ##
  class DogFile
    # @param [String] dogfile
    # @param [String|Object] api_key
    # @param [String|Object] app_key
    # @param [Integer] timeout
    def configure(dogfile, api_key, app_key, timeout)
      @dogfile = dogfile
      @config = DogWatch::Model::Config.new(api_key, app_key, timeout)
    end

    # @param [Proc] block
    def create(&block)
      monitor = instance_eval(IO.read(@dogfile), @dogfile, 1)

      if monitor.is_a?(DogWatch::Monitor)
        monitor.config = @config
        # monitor.client

        # monitor.get
        # monitor.responses.each { |r| block.call(r) }
      else
        klass = Class.new do
          def to_thor
            [:none, 'File does not contain any monitors.', :yellow]
          end
        end

        block.call(klass.new)
      end
    end
  end
end
