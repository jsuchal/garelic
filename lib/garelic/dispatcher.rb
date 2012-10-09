module ActionController
  class Metal < AbstractController::Base
    alias :dispatch_without_garelic :dispatch

    def dispatch(*args)
      Garelic::Metrics.reset!

      response = dispatch_without_garelic(*args)

      timing_data = Garelic.report_user_timing_from_metrics(Garelic::Metrics)

      _, _, chunks = response
      chunks.each do |chunk|
        chunk.gsub!(Garelic::Timing, timing_data)
      end

      response
    end
  end
end