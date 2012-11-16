class Garelic::Middleware
  def initialize(app)
    @app = app
    Garelic::Metrics.reset!
  end

  def call(env)
    status, headers, response = @app.call(env)

    if headers["Content-Type"] =~ /text\/html|application\/xhtml\+xml/
      body = if response.kind_of?(Rack::Response)
                 response.body 
             elsif response.kind_of?(Array)
                 response.first
             else
                 response
             end
      if body.kind_of?(String)
        body.gsub!(Garelic::Timing, Garelic.report_user_timing_from_metrics(Garelic::Metrics))
        response = [body]
      end
    end

    Garelic::Metrics.reset!

    [status, headers, response]
  end
end