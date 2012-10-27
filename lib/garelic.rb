require "garelic/version"
require "garelic/middleware"

class Garelic
  Timing = '<!-- /* GARELIC DATA */ -->'.html_safe

  @@deployed_version_slot = 5

  cattr_accessor :deployed_version, :deployed_version_slot, instance_accessor: false

  def self.monitoring(profile_id)
    buffer = <<-HTML
      <script type="text/javascript">
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{profile_id}']);
          _gaq.push(['_setSiteSpeedSampleRate', 100]);
          #{report_deployed_version}
          _gaq.push(['_trackPageview']);

          #{Garelic::Timing}

          (function() {
              var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
              ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
              var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
      </script>
    HTML
    buffer.html_safe
  end

  def self.report_deployed_version
    "_gaq.push(['_setCustomVar', #{deployed_version_slot}, 'Garelic (Deployed version)', '#{deployed_version}', 3])" unless deployed_version.blank?
  end

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
    initializer 'garelic.install_instrumentation' do |app|
      app.middleware.use Garelic::Middleware

      Garelic::deployed_version = deployed_version_from_git || deployed_version_from_revision_file

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

    def deployed_version_from_git
      `git log --pretty=format:"%cd %h" --date=iso -1 2>/dev/null`.strip.presence
    end

    def deployed_version_from_revision_file
      `cat #{Rails.root}/REVISION 2>/dev/null`.strip.presence
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
      Thread.current[:garelic] ||= {}
      Thread.current[:garelic]
    end
  end
end
