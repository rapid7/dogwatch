require 'ostruct'

module DogWatch
  module Model
    ##
    # Handles the options block methods
    ##
    class Options
      MONITOR_TYPE_OPTIONS_MAP = {
        :metric_alert => [:thresholds].freeze,
        :service_check => [:thresholds].freeze
      }.freeze

      attr_reader :attributes

      # @param [Symbol] monitor_type the monitor type of monitor these
      #   options belong to. This is used to validate monitor type
      #   specific options such as thresholds.
      def initialize(monitor_type = nil)
        @attributes = OpenStruct.new
        @monitor_type = monitor_type
      end

      # @return [Hash]
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

      # @param [Integer] minutes
      def evaluation_delay(minutes)
        @attributes.evaluation_delay = minutes.to_i
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

      # @param [Hash{String=>Fixnum}] thresholds
      def thresholds(thresholds)
        validate_monitor_type_specific_option!(:thresholds)
        @attributes.thresholds = thresholds
      end

      private

      def validate_monitor_type_specific_option!(option)
        options = Array(MONITOR_TYPE_OPTIONS_MAP[@monitor_type])
        return true if options.include?(option)

        # rubocop:disable Metrics/LineLength
        message = "The #{@monitor_type.inspect} monitor type does not support #{option.inspect}."
        message << " Did you mean one of #{options.join(', ')}?" if options.any?
        raise NotImplementedError, message
      end
    end
  end
end
