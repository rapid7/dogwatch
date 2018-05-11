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

      # @param [String] alarm_type
      # @return [String]
      def alarm_type(alarm_type)
        @attributes.alarm_type = alarm_type.to_s
      end

      # @param [String] duration
      # @return [String]
      def duration(duration)
        @attributes.duration = duration.to_s
      end

      # @param [String] threshold
      # @return [String]
      def threshold(threshold)
        @attributes.threshold = threshold.to_s
      end

      # @param [String] team
      # @return [String]
      def team(team)
        @attributes.team = team.to_s
      end

      # @param [String] cluster
      # @return [String]
      def cluster(cluster)
        @attributes.cluster = cluster.to_s
      end

      # @param [String] time_shift
      # @return [String]
      def time_shift(time_shift)
        @attributes.time_shift = time_shift.to_s
      end

      # @param [String] time_window
      # @return [String]
      def time_window(time_window)
        @attributes.time_window = time_window.to_s
      end

      # @param [Array] tags
      # @return [Array]
      def tags(tags)
        @attributes.tags = tags.to_a
      end

      # @param [Array] region
      # @return [Array]
      def region(region=nil)
        @attributes.region = region.to_s
      end

      # @param [Array] stack
      # @return [Array]
      def stack(stack)
        @attributes.stack = stack.to_s
      end

      # @param [Array] service_name
      # @return [Array]
      def service_name(service_name)
        @attributes.service_name = service_name.to_s
      end

      # @param [Array] payload_type
      # @return [Array]
      def payload_type(payload_type)
        @attributes.payload_type = payload_type.to_s
      end

      # @param [Array] payload_subtype
      # @return [Array]
      def payload_subtype(payload_subtype)
        @attributes.payload_subtype = payload_subtype.to_s
      end

      # @param [Array] service_tag
      # @return [Array]
      def service_tag(service_tag)
        @attributes.service_tag = service_tag.to_s
      end

      # @param [Array] team_notify
      # @return [Array]
      def team_notify(team_notify)
        @attributes.team_notify = team_notify.to_s
      end

      # @param [Array] queue
      # @return [Array]
      def queue(queue)
        @attributes.queue = queue.to_s
      end

      # @param [Array] low_urgency_threshold
      # @return [Array]
      def low_urgency_threshold(low_urgency_threshold)
        @attributes.low_urgency_threshold = low_urgency_threshold.to_s
      end

      # @param [Array] high_urgency_threshold
      # @return [Array]
      def high_urgency_threshold(high_urgency_threshold)
        @attributes.high_urgency_threshold = high_urgency_threshold.to_s
      end

      # @param [Array] team_low_urgency_notify
      # @return [Array]
      def team_low_urgency_notify(team_low_urgency_notify)
        @attributes.team_low_urgency_notify = team_low_urgency_notify.to_s
      end

      # @param [Array] team_high_urgency_notify
      # @return [Array]
      def team_high_urgency_notify(team_high_urgency_notify)
        @attributes.team_high_urgency_notify = team_high_urgency_notify.to_s
      end

      # @param [Array] notify_threshold
      # @return [Array]
      def notify_threshold(notify_threshold)
        @attributes.notify_threshold = notify_threshold.to_s
      end

      # @param [Array] severity
      # @return [Array]
      def severity(severity)
        @attributes.severity = severity.to_s
      end

      # @param [Array] notify
      # @return [Array]
      def notify(notify)
        @attributes.notify = notify.to_s
      end

      # @param [Array] consumer_service_name
      # @return [Array]
      def consumer_service_name(consumer_service_name)
        @attributes.consumer_service_name = consumer_service_name.to_s
      end

      # @param [Array] host
      # @return [Array]
      def host(host)
        @attributes.host = host.to_s
      end

      # @param [Array] upstream_service_name
      # @return [Array]
      def upstream_service_name(upstream_service_name)
        @attributes.upstream_service_name = upstream_service_name.to_s
      end

      # @param [Array] cluster_id
      # @return [Array]
      def cluster_id(cluster_id)
        @attributes.cluster_id = cluster_id.to_s
      end

      # @param [Array] node_type
      # @return [Array]
      def node_type(node_type)
        @attributes.node_type = node_type.to_s
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
