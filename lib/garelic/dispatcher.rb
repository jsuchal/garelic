module ActionController
  class Metal < AbstractController::Base
    alias :dispatch_without_garelic :dispatch

    def dispatch(*args)
      response = dispatch_without_garelic(*args)

      timing_data = Garelic.build_user_timing_from_payload(Thread.current[:garelic_payload])

      _, _, chunks = response
      chunks.each do |chunk|
        chunk.gsub!(Garelic::Timing, timing_data)
      end

      response
    end
  end
end