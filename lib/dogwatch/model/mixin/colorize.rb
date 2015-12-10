module DogWatch
  module Model
    module Mixin
      ##
      # Provides a colorize() mixin that handles shell output coloring
      ##
      module Colorize
        def colorize(param, options = {})
          define_method(:color) do
            case instance_variable_get("@#{ param }")
            when *options.fetch(:white, [:status]) then :white
            when *options.fetch(:cyan, [:debug, :trace]) then :cyan
            when *options.fetch(:green, [:info, :success, :create]) then :green
            when *options.fetch(:yellow, [:warn, :update]) then :yellow
            when *options.fetch(:red, [:error, :fail, :delete]) then :red
            else options.fetch(:default, :green)
            end
          end
        end
      end
    end
  end
end
