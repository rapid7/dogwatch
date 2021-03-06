require 'dogapi'
require_relative 'config'
require_relative 'response'

module DogWatch
  module Model
    ##
    # Client interface for the DataDog API
    ##
    class Client
      attr_accessor :client
      attr_accessor :config
      attr_reader :response

      # @param [DogWatch::Model::Config] config
      def initialize(config)
        @config = config
        @client = Dogapi::Client.new(@config.api_key, @config.app_key,
                                     nil, nil, true, @config.timeout)
        @all_monitors = all_monitors
      end

      # @param [DogWatch::Model::Monitor] monitor
      # @return [DogWatch::Model::Response]
      def execute(monitor)
        if monitor_exists?(monitor.name)
          update_monitor(monitor)
        else
          new_monitor(monitor)
        end
      end

      # @param [DogWatch::Model::Monitor] monitor
      # @return [DogWatch::Model::Response]
      def update_monitor(monitor)
        options = options(monitor)
        existing_monitor = get_monitor(monitor.name)
        response = @client.update_monitor(existing_monitor['id'],
                                          monitor.attributes.query,
                                          options)
        updated = %w(200 202).include?(response[0])
        DogWatch::Model::Response.new(response, options[:name], updated)
      end

      # @param [DogWatch::Model::Monitor] monitor
      # @return [DogWatch::Model::Response]
      def new_monitor(monitor)
        options = options(monitor)
        response = @client.monitor(monitor.attributes.type,
                                   monitor.attributes.query,
                                   options)
        DogWatch::Model::Response.new(response, options[:name])
      end

      # @param [Dogwatch::Model::Monitor] monitor
      # @return [Dogwatch::Model::Response]
      def validate(monitor)
        validation = monitor.validate
        return validation if validation.status == :error

        # If no validation errors return a valid Response
        DogWatch::Model::Response.new(['200', {}], 'valid')
      end

      private

      # @param [DogWatch::Model::Monitor] monitor
      # @return [Hash]
      def options(monitor)
        {
          name: monitor.name,
          message: monitor.attributes.message,
          tags: monitor.attributes.tags,
          options: monitor.attributes.options.nil? ? {} : monitor.attributes.options
        }
      end

      # @param [String] name
      # @return [TrueClass|FalseClass]
      def monitor_exists?(name)
        @all_monitors.count { |m| m['name'] == name } > 0
      end

      # @param [String] name
      # @return [Hash]
      def get_monitor(name)
        @all_monitors.find { |m| m['name'] == name }
      end

      # @return [Array]
      def all_monitors
        response = @client.get_all_monitors if @all_monitors.nil?
        @all_monitors = response[1] if response[0] == '200'
        @all_monitors
      end

      # @return [DogWatch::Model::Config]
      def config
        @config = DogWatch::Model::Config.new if @config.nil?
        @config
      end
    end
  end
end
