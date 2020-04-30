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
<%= variable_ize(@monitor.attributes.message) %>
EOF
  query = "<%= variable_ize(@monitor.attributes.query) %>"
  tags = <%= variable_ize(@monitor.attributes.tags.to_s) %>
  require_full_window = false
  <% if defined?(@monitor.attributes.options) %>
  <% if @monitor.attributes.options[:escalation_message] %>escalation_message = <<EOF
<%= variable_ize(@monitor.attributes.options[:escalation_message]) %>
EOF<% end %>
  <% if @monitor.attributes.options[:thresholds] %>thresholds {<% @monitor.attributes.options[:thresholds].each do |k,v| %>
    "<%= k %>": <%= v.to_i %>
    <% end %>}<% end %>
  notify_no_data    = <% if @monitor.attributes.options[:notify_no_data] %><%= @monitor.attributes.options[:notify_no_data] %><% else %>false<% end %>
  <% if @monitor.attributes.options[:renotify_interval] %>renotify_interval = <%= @monitor.attributes.options[:renotify_interval] %><% end %>
  notify_audit =  <% if @monitor.attributes.options[:notify_audit] %><%= @monitor.attributes.options[:notify_audit] %><% else %>false<% end %>
  <% if @monitor.attributes.options[:timeout_h] %>timeout_h    = <%= @monitor.attributes.options[:timeout_h] %><% end %>
  include_tags = <% if @monitor.attributes.options[:include_tags] %><%= @monitor.attributes.options[:include_tags] %><% else %>false<% end %>
  <% if @monitor.attributes.options[:silenced] %>silenced {<% @monitor.attributes.options[:silenced].each do |k,v| %>
    "<%= variable_ize(k) %>": <%= v.to_i %>
    <% end %>}<% end -%>
  <% else %>
  notify_no_data = false
  notify_audit = false
  include_tags = false
  <%= @monitor.attributes.alarm_type %>
  <%= @monitor.attributes.cluster %>
  <% end -%>

}
<% end %>
}
    end


    def get_templates()
      %{
<% for @monitor in @monitors %>
<% if @monitor.attributes.alarm_type == 'cassandra_disk_space_alarms'%>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "cassandra_disk_space_alarms"
  region = "${var.region}"
  threshold = <%= @monitor.attributes.threshold %>
  cluster = "<%= @monitor.attributes.cluster %>"
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
<% if defined?(@monitor.attributes.options) %>
  notify_no_data = <% if @monitor.attributes.options[:notify_no_data] %><%= @monitor.attributes.options[:notify_no_data] %><% else %>false<% end %>
  notify_audit = <% if @monitor.attributes.options[:notify_audit] %><%= @monitor.attributes.options[:notify_audit] %><% else %>false<% end %>
  include_tags = <% if @monitor.attributes.options[:include_tags] %><%= @monitor.attributes.options[:include_tags] %><% else %>false<% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'cassandra_read_alarms'%>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "cassandra_read_alarms"
  region = "${var.region}"
  threshold = <%= @monitor.attributes.threshold %>
  cluster = "<%= @monitor.attributes.cluster %>"
  stack = "${var.stack}"
  <% if @monitor.attributes.duration %>duration = "<%= @monitor.attributes.duration %>"<% end -%>
  time_window = "<%= @monitor.attributes.time_window %>"
  time_shift = "<%= @monitor.attributes.time_shift %>"
  team = "${var.team}"
}
<% elsif @monitor.attributes.alarm_type == 'cassandra_write_alarms'%>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "cassandra_write_alarms"
  region = "${var.region}"
  threshold = <%= @monitor.attributes.threshold %>
  cluster = "<%= @monitor.attributes.cluster %>"
  stack = "${var.stack}"
  <% if @monitor.attributes.duration %>duration = "<%= @monitor.attributes.duration %>"<% end -%>
  time_window = "<%= @monitor.attributes.time_window %>"
  time_shift = "<%= @monitor.attributes.time_shift %>"
  team = "${var.team}"
}
<% elsif @monitor.attributes.alarm_type == 'cassandra_memory_alarms'%>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "cassandra_memory_alarms"
  region = "${var.region}"
  threshold = <%= @monitor.attributes.threshold %>
  cluster = "<%= @monitor.attributes.cluster %>"
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
<% if defined?(@monitor.attributes.options) %>
  notify_no_data = <% if @monitor.attributes.options[:notify_no_data] %><%= @monitor.attributes.options[:notify_no_data] %><% else %>false<% end %>
  notify_audit = <% if @monitor.attributes.options[:notify_audit] %><%= @monitor.attributes.options[:notify_audit] %><% else %>false<% end %>
  include_tags = <% if @monitor.attributes.options[:include_tags] %><%= @monitor.attributes.options[:include_tags] %><% else %>false<% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'unknown_exceptions_alarms'%>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "unknown_exceptions_alarms"
  region = "${var.region}"
  threshold = <%= @monitor.attributes.threshold %>
  duration = "<%= @monitor.attributes.duration %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  stack = "${var.stack}"
  team = "<%= @monitor.attributes.team %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
<% if defined?(@monitor.attributes.options) %>
  notify_no_data = <% if @monitor.attributes.options[:notify_no_data] %><%= @monitor.attributes.options[:notify_no_data] %><% else %>false<% end %>
  notify_audit = <% if @monitor.attributes.options[:notify_audit] %><%= @monitor.attributes.options[:notify_audit] %><% else %>false<% end %>
  include_tags = <% if @monitor.attributes.options[:include_tags] %><%= @monitor.attributes.options[:include_tags] %><% else %>false<% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'known_exceptions_alarms'%>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "known_exceptions_alarms"
  region = "${var.region}"
  threshold = <%= @monitor.attributes.threshold %>
  duration = "<%= @monitor.attributes.duration %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  stack = "${var.stack}"
  team = "<%= @monitor.attributes.team %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
<% if defined?(@monitor.attributes.options) %>
  notify_no_data = <% if @monitor.attributes.options[:notify_no_data] %><%= @monitor.attributes.options[:notify_no_data] %><% else %>false<% end %>
  notify_audit = <% if @monitor.attributes.options[:notify_audit] %><%= @monitor.attributes.options[:notify_audit] %><% else %>false<% end %>
  include_tags = <% if @monitor.attributes.options[:include_tags] %><%= @monitor.attributes.options[:include_tags] %><% else %>false<% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'hystrix_alarms'%>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "hystrix_alarms"
  region = "${var.region}"
  threshold = <%= @monitor.attributes.threshold %>
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
  consumer_service_name = "<%= @monitor.attributes.consumer_service_name %>"
  upstream_service_name = "<%= @monitor.attributes.upstream_service_name %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
<% if defined?(@monitor.attributes.options) %>
  notify_no_data = <% if @monitor.attributes.options[:notify_no_data] %><%= @monitor.attributes.options[:notify_no_data] %><% else %>false<% end %>
  notify_audit = <% if @monitor.attributes.options[:notify_audit] %><%= @monitor.attributes.options[:notify_audit] %><% else %>false<% end %>
  include_tags = <% if @monitor.attributes.options[:include_tags] %><%= @monitor.attributes.options[:include_tags] %><% else %>false<% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'rds_cpu_alarms' || @monitor.attributes.alarm_type == 'rds_replica_lag_alarms' || @monitor.attributes.alarm_type == 'rds_disk_space_alarms' || @monitor.attributes.alarm_type == 'rds_connection_count_alarms' %>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "<%= @monitor.attributes.alarm_type %>"
  region = "${var.region}"
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
  severity = "<%= @monitor.attributes.severity %>"
  notify_threshold = "<%= @monitor.attributes.notify_threshold %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  host = "<%= @monitor.attributes.host %>"
<% if defined?(@monitor.attributes.options) %>
  notify_no_data = <% if @monitor.attributes.options[:notify_no_data] %><%= @monitor.attributes.options[:notify_no_data] %><% else %>false<% end %>
  notify_audit = <% if @monitor.attributes.options[:notify_audit] %><%= @monitor.attributes.options[:notify_audit] %><% else %>false<% end %>
  include_tags = <% if @monitor.attributes.options[:include_tags] %><%= @monitor.attributes.options[:include_tags] %><% else %>false<% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'redis_memory_alarms' || @monitor.attributes.alarm_type == 'redis_cpu_alarms' %>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "<%= @monitor.attributes.alarm_type %>"
  region = "${var.region}"
  threshold = <%= @monitor.attributes.threshold %>
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
  node_type = "<%= @monitor.attributes.node_type %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  cluster_id = "<%= @monitor.attributes.cluster_id %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
<% if defined?(@monitor.attributes.options) %>
  notify_no_data = <% if @monitor.attributes.options[:notify_no_data] %><%= @monitor.attributes.options[:notify_no_data] %><% else %>false<% end %>
  notify_audit = <% if @monitor.attributes.options[:notify_audit] %><%= @monitor.attributes.options[:notify_audit] %><% else %>false<% end %>
  include_tags = <% if @monitor.attributes.options[:include_tags] %><%= @monitor.attributes.options[:include_tags] %><% else %>false<% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'sqs_low_publish_rate_alarms' %>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "<%= @monitor.attributes.alarm_type %>"
  region = "${var.region}"
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
  notify_threshold = "<%= @monitor.attributes.notify_threshold %>"
  service_tag = "<%= @monitor.attributes.service_tag %>"
  payload_type = "<%= @monitor.attributes.payload_type %>"
  payload_subtype = "<%= @monitor.attributes.payload_subtype %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
<% if defined?(@monitor.attributes.options) %>
  <% if @monitor.attributes.options[:renotify_interval] %>renotify_interval = <%= @monitor.attributes.options[:renotify_interval] %><% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'sqs_queue_backup_alarms_low_urgency' %>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "<%= @monitor.attributes.alarm_type %>"
  region = "${var.region}"
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
  notify_threshold = "<%= @monitor.attributes.notify_threshold %>"
  service_tag = "<%= @monitor.attributes.service_tag %>"
  payload_type = "<%= @monitor.attributes.payload_type %>"
  payload_subtype = "<%= @monitor.attributes.payload_subtype %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
  low_urgency_threshold = "<%= @monitor.attributes.low_urgency_threshold %>"
<% if defined?(@monitor.attributes.options) %>
  <% if @monitor.attributes.options[:renotify_interval] %>renotify_interval = <%= @monitor.attributes.options[:renotify_interval] %><% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'sqs_queue_backup_alarms_high_urgency' %>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "<%= @monitor.attributes.alarm_type %>"
  region = "${var.region}"
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
  notify_threshold = "<%= @monitor.attributes.notify_threshold %>"
  service_tag = "<%= @monitor.attributes.service_tag %>"
  payload_type = "<%= @monitor.attributes.payload_type %>"
  payload_subtype = "<%= @monitor.attributes.payload_subtype %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
  high_urgency_threshold = "<%= @monitor.attributes.high_urgency_threshold %>"
<% if defined?(@monitor.attributes.options) %>
  <% if @monitor.attributes.options[:renotify_interval] %>renotify_interval = <%= @monitor.attributes.options[:renotify_interval] %><% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'sqs_retry_queue_backup_alarms_high_urgency' %>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "<%= @monitor.attributes.alarm_type %>"
  region = "${var.region}"
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
  notify_threshold = "<%= @monitor.attributes.notify_threshold %>"
  service_tag = "<%= @monitor.attributes.service_tag %>"
  payload_type = "<%= @monitor.attributes.payload_type %>"
  payload_subtype = "<%= @monitor.attributes.payload_subtype %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
  high_urgency_threshold = "<%= @monitor.attributes.high_urgency_threshold %>"
<% if defined?(@monitor.attributes.options) %>
  <% if @monitor.attributes.options[:renotify_interval] %>renotify_interval = <%= @monitor.attributes.options[:renotify_interval] %><% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'sqs_retry_queue_backup_alarms_low_urgency' %>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "<%= @monitor.attributes.alarm_type %>"
  region = "${var.region}"
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
  notify_threshold = "<%= @monitor.attributes.notify_threshold %>"
  service_tag = "<%= @monitor.attributes.service_tag %>"
  payload_type = "<%= @monitor.attributes.payload_type %>"
  payload_subtype = "<%= @monitor.attributes.payload_subtype %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
  low_urgency_threshold = "<%= @monitor.attributes.low_urgency_threshold %>"
<% if defined?(@monitor.attributes.options) %>
  <% if @monitor.attributes.options[:renotify_interval] %>renotify_interval = <%= @monitor.attributes.options[:renotify_interval] %><% end %>
<% end %>
}
<% elsif @monitor.attributes.alarm_type == 'sqs_payload_giveup_alarms' %>
module "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  source = "<%= @monitor.attributes.alarm_type %>"
  region = "${var.region}"
  threshold = <%= @monitor.attributes.threshold %>
  stack = "${var.stack}"
  duration = "<%= @monitor.attributes.duration %>"
  team = "<%= @monitor.attributes.team %>"
  notify_threshold = "<%= @monitor.attributes.notify_threshold %>"
  service_tag = "<%= @monitor.attributes.service_tag %>"
  payload_type = "<%= @monitor.attributes.payload_type %>"
  payload_subtype = "<%= @monitor.attributes.payload_subtype %>"
  service_name = "<%= @monitor.attributes.service_name %>"
  team_notify = "<%= @monitor.attributes.team_notify %>"
}
<% elsif @monitor.attributes.alarm_type != 'NONE'%>
resource "datadog_monitor" "<%= (Digest::SHA256.bubblebabble @monitor.name).gsub('-', '_') %>" {
  name               = "<%= variable_ize(@monitor.name) %>"
  type               = "<%= @monitor.attributes.type %>"
  message            = <<EOF
<%= variable_ize(@monitor.attributes.message) %>
EOF
  query = "<%= variable_ize(@monitor.attributes.query) %>"
  tags = <%= variable_ize(@monitor.attributes.tags.to_s) %>
  require_full_window = false
  <% if defined?(@monitor.attributes.options) %>
  <% if @monitor.attributes.options[:escalation_message] %>escalation_message = <<EOF
<%= variable_ize(@monitor.attributes.options[:escalation_message]) %>
EOF<% end %>
  <% if @monitor.attributes.options[:thresholds] %>thresholds {<% @monitor.attributes.options[:thresholds].each do |k,v| %>
    "<%= k %>": <%= v.to_i %>
    <% end %>}<% end %>
  notify_no_data    = <% if @monitor.attributes.options[:notify_no_data] %><%= @monitor.attributes.options[:notify_no_data] %><% else %>false<% end %>
  <% if @monitor.attributes.options[:renotify_interval] %>renotify_interval = <%= @monitor.attributes.options[:renotify_interval] %><% end %>
  notify_audit =  <% if @monitor.attributes.options[:notify_audit] %><%= @monitor.attributes.options[:notify_audit] %><% else %>false<% end %>
  <% if @monitor.attributes.options[:timeout_h] %>timeout_h    = <%= @monitor.attributes.options[:timeout_h] %><% end %>
  include_tags = <% if @monitor.attributes.options[:include_tags] %><%= @monitor.attributes.options[:include_tags] %><% else %>false<% end %>
  <% if @monitor.attributes.options[:silenced] %>silenced {<% @monitor.attributes.options[:silenced].each do |k,v| %>
    "<%= variable_ize(k) %>": <%= v.to_i %>
    <% end %>}<% end -%>
  <% else %>
  notify_no_data = false
  notify_audit = false
  include_tags = false
  <% end -%>
}
<% end %>
<% end %>
}

    end
    def export
      monitor = instance_eval(IO.read(@dogfile), @dogfile, 1)
      if monitor.is_a?(DogWatch::Monitor)
        print ERB.new(get_templates, nil, '-').result(monitor.get_binding)
      else
        print 'Unexpected file content!'
      end
    end

    def export_names
      monitor = instance_eval(IO.read(@dogfile), @dogfile, 1)
      if monitor.is_a?(DogWatch::Monitor)
        monitor.monitors.each {|m|
          printf "%s\t%s\n",  Digest::SHA256.bubblebabble(m.name.gsub('razor-prod-0', '${var.stack}').gsub('eu-central-1', '${var.region}')).gsub('-', '_'), CGI::escape(m.name)
        }
      else
        print 'Unexpected file content!'
      end
    end

  end
end
