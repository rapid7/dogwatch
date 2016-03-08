# DogWatch

_A DSL to create DataDog monitors_

This gem is designed to provide a simple method for creating DataDog monitors in Ruby.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'dogwatch'
```

And then execute:
```shell
$ bundle exec dogwatch create [--dogfile=DOGFILE] [--api_key=API KEY] [--app_key=APP KEY]
```
Or install it yourself as:
```shell
$ gem install dogwatch
```

## Credentials
[DataDog API credentials](https://app.datadoghq.com/account/settings#api) are required.

Generate both an api key and an app key and either place them in a file named `~/.dogwatch/credentials` or pass them via the command line.

A sample credentials file is provided in the `example` directory.

In order to generate these keys, log into your Datadog account.  From there, click on 'Integrations->APIs'.  Keep in mind, your org may be allowed only five API Keys.
## Usage

DogWatch is a thin DSL over the [DataDog ruby client](https://github.com/DataDog/dogapi-rb) that handles generating DataDog monitors.

The following is an example of a `Dogfile`:
```ruby
DogWatch.monitor do
  ## Create a new monitor - monitor name is REQUIRED
  monitor 'MONITOR NAME' do
    type :metric_alert # REQUIRED: One of [:metric_alert | :service_check | :event_alert]
    query 'time_aggr(time_window):space_aggr:metric{tags} [by {key}] operator' # REQUIRED
    message 'MESSAGE'
    tags %w(A list of tags to associate with your monitor)

    options do
      silenced '*': nil
      notify_no_data false
      no_data_timeframe 3
      timeout_h 99
      renotify_interval 60
      escalation_message 'oh snap'
      include_tags true
    end
  end
end
```
Queries are the combination of several items including a time aggregator (over a window of time), space aggregator (avg, sum, min, or max), a set of tags and an optional order by, and an operator.

From the Datadog documentation:

```
time_aggr(time_window):space_aggr:metric{tags} [by {key}] operator 
```
An example of a query:

```
avg(last_15m):avg:system.disk.used{region:us-east-1,some-tag:some-tag-value,device:/dev/xvdb} by {cluster} * 100 > 55
```

Monitors that already exist are matched by name and updated accordingly. If the name isn't matched exactly, DogWatch assumes you want a new monitor.

A sample `Dogfile` is provided in the `example` directory.

For a full list of options and a description of each parameter, see [DataDog's API documentation](http://docs.datadoghq.com/api/#monitors).

## TO DO
* More descriptive errors
* Better error handling if a monitor fails local validation
