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
               :yellow => [],
               :red => [:error])

      attr_accessor :response

      def initialize(response, name, updated = false)
        @response = response
        @updated = updated
        @name = if response[1]['name'].nil?
                  name
                else
                  response[1]['name']
                end
      end

      def status
        return :updated if @updated == true
        return :created if created?
        return :error if failed?
        return :accepted if accepted?
      end

      def message
        send(status, @response[1])
      end

      def to_thor
        action = status
        text = message
        [action, text, color]
      end

      private

      def error(attrs)
        err = attrs['errors'].join(', ')
        "The following errors occurred when creating monitor #{@name}: #{err}"
      end

      def created(attrs)
        "Created monitor #{@name} with message #{attrs['message']}"
      end

      def updated(attrs)
        # TODO: Use some kind of statefile to determine diffs between
        # previously saved model and new version
        "Updated monitor #{@name} with message #{attrs['message']}"
      end

      def accepted(attrs)
        "Accepted monitor #{@name} with message #{attrs['message']}"
      end

      def accepted?
        @response[0] == ACCEPTED
      end

      def created?
        @response[0] == CREATED
      end

      def failed?
        @response[0] == ERROR
      end
    end
  end
end
