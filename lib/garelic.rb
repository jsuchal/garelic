require "garelic/version"
require "garelic/dispatcher"

class Garelic
  Timing = '<!-- /* GARELIC DATA */ -->'.html_safe

  def self.build_user_timing_from_payload(payload)
    action_identifier = "#{payload[:controller]}##{payload[:action]}"
    [
        track_timing('Garelic', 'Response (Total)', payload[:total_runtime], action_identifier),
        track_timing('Garelic', 'Response (Views)', payload[:view_runtime], action_identifier),
        track_timing('Garelic', 'Response (ActiveRecord)', payload[:db_runtime], action_identifier),
    ].join("\n")
  end

  def self.track_timing(category, variable, time, opt_label = nil, opt_sample = nil)
    parameters = ["'#{category}'", "'#{variable}'", time.to_i]
    parameters << "'#{opt_label}'" if opt_label
    parameters << opt_sample if opt_sample
    "_gaq.push(['_trackTiming', #{parameters.join(', ')}]);"
  end

  class Railtie < Rails::Railtie
    initializer 'garelic.install_instrumentation' do
      ActiveSupport::Notifications.subscribe('process_action.action_controller') do |_, start, finish, _, payload|
        payload[:total_runtime] = (finish - start) * 1000
        Thread.current[:garelic_payload] = payload
      end
    end
  end
end
