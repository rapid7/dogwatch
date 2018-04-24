require 'erb'
require 'digest/bubblebabble'

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

    def get_template()
%{
<% for @monitor in @monitors %>
resource "datadog_monitor" "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  name               = "<%= variable_ize(@monitor.name) %>"
  type               = "<%= @monitor.attributes.type %>"
  message            = <<EOF
<%= variable_ize(@monitor.attributes.message) %>"
EOF
  query = "<%= variable_ize(@monitor.attributes.query) %>"
  <% if defined?(@monitor.attributes.options) %>
  <% if @monitor.attributes.options[:escalation_message] %>escalation_message = <<EOF
<%= variable_ize(@monitor.attributes.options[:escalation_message]) %>
EOF<% end %>
  <% if @monitor.attributes.options[:thresholds] %>thresholds {<% @monitor.attributes.options[:thresholds].each do |k,v| %>
    "<%= k %>": <%= v.to_i %>
    <% end %>}<% end %>
  <% if @monitor.attributes.options[:notify_no_data] %>notify_no_data    = <%= @monitor.attributes.options[:notify_no_data] %><% end %>
  <% if @monitor.attributes.options[:renotify_interval] %>renotify_interval = <%= @monitor.attributes.options[:renotify_interval] %><% end %>
  <% if @monitor.attributes.options[:notify_audit] %>notify_audit =  <%= @monitor.attributes.options[:notify_audit] %><% end %>
  <% if @monitor.attributes.options[:timeout_h] %>timeout_h    = <%= @monitor.attributes.options[:timeout_h] %><% end %>
  <% if @monitor.attributes.options[:include_tags] %>include_tags = <%= @monitor.attributes.options[:include_tags] %><% end %>
  <% if @monitor.attributes.options[:silenced] %>silenced {<% @monitor.attributes.options[:silenced].each do |k,v| %>
    "<%= variable_ize(k) %>": <%= v.to_i %>
    <% end %>}<% end %>
  <% end %>

  tags = <%= variable_ize(@monitor.attributes.tags.to_s) %>
}
<% end %>
}
    end

    def export
      monitor = instance_eval(IO.read(@dogfile), @dogfile, 1)
      if monitor.is_a?(DogWatch::Monitor)
        print ERB.new(get_template).result(monitor.get_binding)
      else
        print 'Unexpected file content!'
      end
    end
  end
end
