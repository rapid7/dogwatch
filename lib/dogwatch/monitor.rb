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
        if m.validate
          @client.execute(m)
        else
          # Need somewhere to inject local errors such as if the request
          # was never sent because the type or query wasn't supplied.
          res = ['400', { 'errors' => ['The DogWatch monitor is invalid.'] }]
          DogWatch::Model::Response.new(res, 'error')
        end
      end
    end

    # @return [DogWatch::Model::Client]
    def client(client = nil)
      @client = client.nil? ? DogWatch::Model::Client.new(@config) : client
    end
  end
end
