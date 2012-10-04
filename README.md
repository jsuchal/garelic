# Garelic: Use Google Analytics as "New Relic" performance monitoring for your Rails app

This gem uses Google Analytics User Timing API to report application performance statistics directly to Google Analytics, where you can slice & dice your data as you wish.

Here are some features with pictures:

- [Performance reports as a nice dashboard](http://twitpic.com/b0gt4j/full)
- [Histogram of response times for action](http://twitpic.com/b0gv6e/full)
- [Identify slow page loads & drill down to different actions](http://twitpic.com/b0gump/full)
- [Showing average response times for each action](http://twitpic.com/b0gwkx/full)
- [How much is spent in database & view generation for an action?](http://twitpic.com/b0h062/full)
- [How has the yesterdays switch to Ruby 1.9.3 affected response time?](http://twitpic.com/b11mxm/full)

*This is a proof of concept and will probably break things. Use it at your own risk.*


## Installation

It's easy as 1-2-3.

*Step 1.* Add this line to your application's Gemfile:

    gem 'garelic'

*Step 2.* Add `<%= Garelic::Timing %>` instrumentation to your GA code in application layout template like this:

    <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-XXXXXXXX-X']);
        _gaq.push(['_setSiteSpeedSampleRate', 100]);
        _gaq.push(['_trackPageview']);

        <%= Garelic::Timing %>

        (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
    </script>
    
(Please note the `_gaq.push(['_setSiteSpeedSampleRate', 100]);` code for better testing.)

*Step 3.* Go to Google Analytics > Content > Site Speed > User Timings

Enjoy!

## Know advantages

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

- add more fine-grained ActiveRecord instrumentation
- add support for adding custom user tracers (e.g. for external services)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
