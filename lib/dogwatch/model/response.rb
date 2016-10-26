require_relative 'mixin/colorize'

module DogWatch
  module Model
    ##
    # Takes DataDog client responses and formats them nicely
    ##
    class Response
      extend Mixin::Colorize

      ERROR = '400'.freeze
      CREATED = '200'.freeze
      ACCEPTED = '202'.freeze
      colorize(:action,
               :green => [:created, :accepted, :updated],
               :yellow => [:deleted],
               :red => [:error])

      attr_accessor :response

      def initialize(response, updated = false)
        @response = response
        @updated = updated
      end

      def status
        return :deleted if deleted?
        return :updated if @updated == true
        return :created if created?
        return :error if failed?
        return :accepted if accepted?
      end

      def message
        attrs = @response[1]
        return attrs['errors'] if attrs.key?('errors')
        name = attrs.key?('deleted_monitor_id') ? "(id was: #{attrs['deleted_monitor_id']})" : attrs['name']

        "#{status.to_s.capitalize} monitor #{name}"\
        " with message #{attrs['message']}"
      end

      def to_thor
        action = status
        text = message
        [action, text, color]
      end

      private

      def accepted?
        @response[0] == ACCEPTED ? true : false
      end

      def created?
        @response[0] == CREATED ? true : false
      end

      def deleted?
        @response[1].key?('deleted_monitor_id')
      end

      def failed?
        @response[0] == ERROR ? true : false
      end
    end
  end
end
