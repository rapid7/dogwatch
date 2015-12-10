require 'ostruct'

module DogWatch
  module Model
    ##
    # Handles the options block methods
    ##
    class Options
      attr_reader :attributes

      def initialize
        @attributes = OpenStruct.new
      end

      def render
        @attributes.each_pair.to_h
      end

      # @param [Hash] args
      def silenced(args)
        @attributes.silenced = args.to_h
      end

      # @param [Boolean] notify
      def notify_no_data(notify = false)
        @attributes.notify_no_data = !!notify
      end

      # @param [Integer] minutes
      def no_data_timeframe(minutes)
        @attributes.no_data_timeframe = minutes.to_i
      end

      # @param [Integer] hours
      def timeout_h(hours)
        @attributes.timeout_h = hours.to_i
      end

      # @param [Integer] minutes
      def renotify_interval(minutes)
        @attributes.renotify_interval = minutes.to_i
      end

      # @param [String] message
      def escalation_message(message)
        @attributes.escalation_message = message.to_s
      end

      # @param [Boolean] notify
      def notify_audit(notify = false)
        @attributes.notify_audit = !!notify
      end

      # @param [Boolean] include
      def include_tags(include = true)
        @attributes.include_tags = !!include
      end
    end
  end
end
