require 'yaml'

module DogWatch
  module Model
    ##
    # Manages API configuration. Currently handles
    # credential only.
    ##
    class Config
      attr_accessor :api_key
      attr_accessor :app_key

      # @param [String] api_key
      # @param [String] app_key
      def initialize(api_key = nil, app_key = nil)
        @api_key = api_key unless api_key.nil?
        @app_key = app_key unless app_key.nil?
        return unless app_key.nil? || api_key.nil?

        from_file
      end

      def from_file
        begin
          config_file = IO.read("#{Dir.home}/.dogwatch/credentials")
        rescue
          raise('No credentials supplied')
        end

        credentials = YAML.load(config_file)
        @api_key = credentials['api_key']
        @app_key = credentials['app_key']
      end
    end
  end
end
