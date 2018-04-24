require_relative 'model/client'
require_relative 'model/monitor'

module DogWatch
  ##
  # Provides a container around each monitor block
  ##
  class Monitor
    attr_reader :client
    attr_reader :responses
    attr_accessor :config

    # @param [String] name
    # @param [Proc] block
    # @return [DogWatch::Model::Monitor]
    def initialize(name = nil, &block)
      @name = name
      @monitors = []
      @config = nil
      instance_exec(&block)
    end

    # @param [String] name
    # @param [Proc] block
    # @return [Array]
    def monitor(name, &block)
      monitor = DogWatch::Model::Monitor.new(name)
      monitor.instance_eval(&block)
      @monitors << monitor
    end

    # @return [Array]
    def get
      @responses = @monitors.map do |m|
        validate = @client.validate(m)
        if validate.status == :error
          validate
        else
          @client.execute(m)
        end
      end
    end

    # @return [DogWatch::Model::Client]
    def client(client = nil)
      @client = if client.nil?
                  DogWatch::Model::Client.new(@config)
                else
                  client
                end
    end

    def variable_ize(str)
      str.gsub('eu-central-1', '${var.region}')
          .gsub('razor-prod-0', '${var.stack}')
    end

    # Expose private binding() method.
    def get_binding
      binding()
    end
  end
end
