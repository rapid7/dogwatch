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

      # @return [DogWatch::Model::Response]
      def validate
        return DogWatch::Model::Response.new(invalid_type_response, 'invalid') \
          unless TYPE_MAP.key?(@monitor_type)

        errors = []
        errors.push('Missing monitor type') if missing_type?
        errors.push('Missing monitor query') if missing_query?

        if errors.empty?
          DogWatch::Model::Response.new(['200', { :message => 'valid' }], 'valid')
        else
          DogWatch::Model::Response.new(['400', { 'errors' => errors }], 'invalid')
        end
      end

      private

      def valid_types
        TYPE_MAP.keys.map { |k| ":#{k}" }.join(', ')
      end

      def missing_type?
        @attributes.type.nil? || @attributes.type.empty?
      end

      def missing_query?
        @attributes.query.nil? || @attributes.query.empty?
      end

      def invalid_type_response
        [
          '400',
          { 'errors' => [
            "Monitor type '#{@monitor_type}' is not valid. " \
            "Valid monitor types are: #{valid_types}"
          ] }
        ]
      end
    end
  end
end
