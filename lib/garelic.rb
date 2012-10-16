require "garelic/version"
require "garelic/dispatcher"

class Garelic
  Timing = '<!-- /* GARELIC DATA */ -->'.html_safe

  def self.report_user_timing_from_metrics(metrics)
    reports = report_user_timing_for_action(metrics[:action], metrics.action_identifier)
    reports += report_user_timing_for_active_record(metrics[:active_record], metrics.action_identifier)

    reports.join("\n")
  end

  def self.report_user_timing_for_action(metrics, action_identifier)
    [
        track_timing('Garelic (Controller)', 'Response time (Total)', metrics[:total_runtime], action_identifier),
        track_timing('Garelic (Controller)', 'Response time (Views)', metrics[:view_runtime], action_identifier),
        track_timing('Garelic (Controller)', 'Response time (ActiveRecord)', metrics[:db_runtime], action_identifier),
    ]
  end

  def self.report_user_timing_for_active_record(metrics, action_identifier)
    timings = []
    metrics.each do |call_type, time|
      timings << track_timing('Garelic (ActiveRecord)', call_type, time, action_identifier)
    end
    timings
  end

  def self.track_timing(category, variable, time, opt_label = nil, opt_sample = nil)
    parameters = ["'#{category}'", "'#{variable}'", time.to_i]
    parameters << "'#{opt_label}'" if opt_label
    parameters << opt_sample if opt_sample
    "_gaq.push(['_trackTiming', #{parameters.join(', ')}]);"
  end

  class Railtie < Rails::Railtie
    initializer 'garelic.install_instrumentation' do
      Garelic::Metrics.reset!

      ActiveSupport::Notifications.subscribe('process_action.action_controller') do |_, start, finish, _, payload|
        Garelic::Metrics.report(:action, :db_runtime, payload[:db_runtime] || 0)
        Garelic::Metrics.report(:action, :view_runtime, payload[:view_runtime] || 0)
        Garelic::Metrics.report(:action, :total_runtime, (finish - start) * 1000)
        Garelic::Metrics.action_identifier = "#{payload[:controller]}##{payload[:action]}"
      end

      ActiveSupport::Notifications.subscribe('sql.active_record') do |_, start, finish, _, payload|
        type = payload[:name] || 'Other SQL'
        Garelic::Metrics.report(:active_record, type, (finish - start) * 1000) if type != 'CACHE'
      end
    end
  end

  class Metrics
    def self.reset!
      Thread.current[:garelic] = {}
      Thread.current[:garelic_action] = nil
    end

    def self.action_identifier=(value)
      Thread.current[:garelic_action] = value
    end

    def self.action_identifier
      Thread.current[:garelic_action]
    end

    def self.report(category, variable, runtime, payload = nil)
      metrics[category] ||= Hash.new(0)
      metrics[category][variable] += runtime
    end

    def self.[](category)
      metrics[category] || {}
    end

    private
    def self.metrics
      Thread.current[:garelic]
    end
  end
end
