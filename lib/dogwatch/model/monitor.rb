require 'ostruct'
require_relative 'options'

module DogWatch
  module Model
    ##
    # Handles monitor DSL methods and object validation
    ##
    class Monitor
      TYPE_MAP = {
        metric_alert: 'metric alert',
        service_check: 'service check',
        event_alert: 'event alert'
      }.freeze

      attr_reader :name
      attr_reader :attributes

      # @param [String] name
      # @return [String]
      def initialize(name)
        @attributes = OpenStruct.new
        @name = name
      end

      # @param [Symbol] type
      # @return [String]
      def type(type)
        @monitor_type = type
        @attributes.type = TYPE_MAP[type]
      end

      # @param [String] query
      # @return [String]
      def query(query)
        @attributes.query = query.to_s
      end

      # @param [String] message
      # @return [String]
      def message(message)
        @attributes.message = message.to_s
      end

      # @param [Array] tags
      # @return [Array]
      def tags(tags)
        @attributes.tags = tags.to_a
      end

      # @param [Proc] block
      # @return [Hash]
      def options(&block)
        opts = DogWatch::Model::Options.new(@monitor_type)
        opts.instance_eval(&block)
        @attributes.options = opts.render
      end

      # @return [TrueClass|FalseClass]
      def validate
        return false unless TYPE_MAP.value?(@attributes.type)
        return true unless @attributes.type.nil? || @attributes.type.empty? ||
                           @attributes.query.nil? || @attributes.query.empty?

        false
      end
    end
  end
end
