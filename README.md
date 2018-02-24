# Nexaas::Throttle

[![Build Status](https://travis-ci.org/myfreecomm/nexaas-throttle.svg?branch=master)](https://travis-ci.org/myfreecomm/nexaas-throttle)
[![Test Coverage](https://codeclimate.com/github/myfreecomm/nexaas-throttle/badges/coverage.svg)](https://codeclimate.com/github/myfreecomm/nexaas-throttle/coverage)
[![Code Climate](https://codeclimate.com/github/myfreecomm/nexaas-throttle/badges/gpa.svg)](https://codeclimate.com/github/myfreecomm/nexaas-throttle)

A configurable Rails engine that provides a common way of reducing API abuse, throttling consumers' requests and blocking undesired pentesters and robots.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nexaas-throttle'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nexaas-throttle

## Usage

In a Rails initializer file such as `config/initializers/nexaas_throttle.rb`, put something like this:

```ruby
require "nexaas/throttle"

Nexaas::Throttle.configure do |config|
  config.throttle = true
  config.track = true
  config.period = 1.minute
  config.limit = 2
  config.request_identifier = MyRequestIdentifier
  config.redis_options = {
    host: "localhost",
    port: 6379,
    db: 0,
    namespace: "nexaas:throttle"
  }
  config.ignored_user_agents = [/[Gg]oogle/, /Amazon/]
  config.assets_extensions = %w[bmp tiff css js jpg jpeg png gif woff ttf svg]
end
```

### Configuration

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>throttle</code></td>
    <td>Whether or not requests are throttled.</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><code>track</code></td>
    <td>Whether or not requests are tracked.</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td><code>period</code></td>
    <td>The size of the throttle window.</td>
    <td><code>1 minute</code></td>
  </tr>
  <tr>
    <td><code>limit</code></td>
    <td>How many requests a consumer can do during a window until he starts being throttled.</td>
    <td><code>60 requests</code></td>
  </tr>
  <tr>
    <td><code>request_identifier</code></td>
    <td>The class that will handle request identification. See <a href="#request-identification">Request Identification</a> for more details.</td>
    <td><code>nil</code></td>
  </tr>
  <tr>
    <td><code>redis_options</code></td>
    <td>Redis hash configuration where requests counters are persisted.</td>
    <td>
      <pre>
{
  host: "localhost",
  port: 6379,
  db: 0,
  namespace: "nexaas:throttle"
}
      </pre>
    </td>
  </tr>
  <tr>
    <td><code>ignored_user_agents</code></td>
    <td>An array of User Agents that should be ignored by the throttler. Values are regexes that will be matched against the request User-Agent</td>
    <td><code>nil</code></td>
  </tr>
  <tr>
    <td><code>assets_extensions</code></td>
    <td>An array of file extensions considered to be asset-related. Values are strings that will be matched against the request path. Paths that match will be not be throttled</td>
    <td><code>%w[css js jpg jpeg png gif woff ttf svg]</code></td>
  </tr>
</table>

### Request Identification

`Nexaas::Throttle` doesn't know how to identify a consumer. Some applications might rely on request IP, others on an API TOKEN. You must provide a way of getting an unique token
that identify a request consumer.

If there is no token, the request will go through and won't be accounted for.

`Nexaas::Throttle` do this by providing a configuration `request_identifier`, a class where your application would keep the logic that identifies a consumer. This class must have the following
interface:

```ruby
class MyRequestIdentifier
  def initialize(request)
    @request = request
  end

  def token
    @request.ip
    # or @request.env["HTTP_AUTHORIZATION"]
    # or User.find_by(token: @request.params[:token])
    # or Cache.read(@request.params[:token])
  end
end
```

### Tracking requests

In order to track your requests, you must subscribe to a event triggered by `Rack::Attack` gem as below:

```ruby
ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, request|
  if request.env["rack.attack.matched"] == "nexaas/track" && request.env["rack.attack.match_type"] == :track
    # Put your tracking logic here
    # You can use request.env["nexaas.token"] to obtain the token provided by your request_identifier
  end
end
```

If you want, you can access the request token by inspecting `request.env["nexaas.token"]`. This is the token your `request_identifier` provided after evaluating the request.

### Response headers

Rate limit headers are available for all request responses and provide information for API users. They are the following:

```ruby
"X-RateLimit-Limit"     # Total of requests allowed until next reset.
"X-RateLimit-Remaining" # Amount of requests the user can still send before being throttled.
"X-RateLimit-Reset"     # Epoch time for the reset of the request count.
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/myfreecomm/nexaas-throttle.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
