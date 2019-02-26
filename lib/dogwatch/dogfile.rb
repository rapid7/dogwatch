require 'rhcl'

require_relative 'model/config'
require_relative 'model/client'

module DogWatch
  ##
  # Manage the execution of the Dogfile
  ##
  class DogFile
    # @param [String] dogfile
    # @param [String|Object] api_key
    # @param [String|Object] app_key
    # @param [Integer] timeout
    def configure(dogfile, api_key, app_key, timeout)
      @dogfile = dogfile
      @config = DogWatch::Model::Config.new(api_key, app_key, timeout)
    end

    # @param [Proc] block
    def create(&block)
      monitor = instance_eval(IO.read(@dogfile), @dogfile, 1)

      if monitor.is_a?(DogWatch::Monitor)
        monitor.config = @config
        monitor.client

        monitor.get
        monitor.responses.each { |r| block.call(r) }
      else
        klass = Class.new do
          def to_thor
            [:none, 'File does not contain any monitors.', :yellow]
          end
        end

        block.call(klass.new)
      end
    end

    def to_terraform(&block)
      monitors = instance_eval(IO.read(@dogfile), @dogfile, 1)
      tf_monitors = {}
      monitors.instance_variable_get(:@monitors).map do |monitor|
        new_monitor = monitor.instance_variable_get(:@attributes).to_h

        new_monitor.map do |key, val|
          if val.is_a? String
            new_monitor[key] = generify_string_to_terraform(val)
          end
        end

        if new_monitor.key?(:options)
          new_monitor[:options].map do |key, val|
            new_monitor[key] = val
          end
          new_monitor.delete(:options)
        end

        if new_monitor.key?(:tags)
          new_monitor[:tags] = generify_list_to_terraform(new_monitor[:tags])
        end
        name = generify_string_to_terraform(monitor.instance_variable_get(:@name))
        tf_monitors[name] = new_monitor
      end
      tf_monitors.map do |key, val|
        puts 'resource "datadog_monitor" ' + Rhcl.dump(key => val)
        puts "\n"
      end
    end

    def generify_list_to_terraform(list)
      new_list = []
      list.each do |item|
        new_list.push(generify_string_to_terraform(item))
      end
      new_list
    end

    def generify_string_to_terraform(item)
      item.gsub!(/razor-prod-[0-9]/, '${var.stack}')
      item.gsub!(/(ap|us|eu|sa|ca)-[a-z]+-[0-9]{1}/, '${var.region}')
      item
    end

 end
end
