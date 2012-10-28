# Garelic: Use Google Analytics as "New Relic" performance monitoring for your Rails app

This gem uses Google Analytics User Timing API to report application performance statistics directly to Google Analytics, where you can slice & dice your data as you wish.

Here are some features with pictures:

- [Performance reports as a nice dashboard](http://twitpic.com/b0gt4j/full)
- [Histogram of response times for action](http://twitpic.com/b0gv6e/full)
- [Identify slow page loads & drill down to different actions](http://twitpic.com/b0gump/full)
- [Showing average response times for each action](http://twitpic.com/b0gwkx/full)
- [How much is spent in database & view generation for an action?](http://twitpic.com/b0h062/full)
- [How has the switch to Ruby 1.9.3 affected response time?](http://twitpic.com/b11mxm/full)
- [In which action do we spent most time globaly?](http://twitpic.com/b15l7j/full)
- *NEW (in 0.1.0)* [ActiveRecord queries drilldown](http://twitpic.com/b2o26x/full)
- *NEW (in 0.2.0)* [Deployment performance comparison](http://twitpic.com/b8ai3l/full)


## Installation

It's easy as 1-2-3.

*Step 1.* Add this line to your application's Gemfile:

    gem 'garelic'

*Step 2.* Add `<%= Garelic::Monitoring 'UA-XXXXXX-X' %>` instrumentation in application layout template (before the closing `</head>` tag) like this:

    <head>
        <!-- other rails stuff -->
        <%= Garelic::Monitoring 'UA-XXXXXX-X' %>
    </head>

*Step 3.* Go to Google Analytics > Content > Site Speed > User Timings

Enjoy!

## Known advantages

- it's free
- shows slow performing pages (not only actions)
- show response times histogram for any action (response time averages tend to lie, since distribution of response times is multimodal)
- segment/slice/dice response data across any dimensions available in your GA account

## Known drawbacks

- you can only track actions that return a response body (redirects, ajax-requests & async jobs are not supported)
- all timings are visible in page source code (if you are concerned about this look elsewere)
- caching GA code (e.g. page caching) & not modified response will probably break/skew reported statistics
- adding user timing table widgets to GA dashboards does not preserve sorting order (wtf?)
- it's kind of a hack

## TODO

- add support for adding custom user tracers (e.g. for external services)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
