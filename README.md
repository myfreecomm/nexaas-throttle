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
  config.period = 1.minute

  config.limit = 2

  config.request_identifier = MyRequestIdentifier

  config.redis_options = {
    host: "localhost",
    port: 6379,
    db: 0,
    namespace: "nexaas:throttle"
  }
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
    <td><code>period</code></td>
    <td>The size of the throttle window.</td>
    <td>1 minute</td>
  </tr>
  <tr>
    <td><code>limit</code></td>
    <td>How many requests a consumer can do during a window until he starts being throttled.</td>
    <td>60 requests</td>
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
</table>

### Request Identification

`Nexaas::Throttle` doesn't know how to identify a consumer. Some applications might rely on request IP, others on an API TOKEN. You must provide a way of getting an unique token
that identify a request consumer.

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/myfreecomm/nexaas-throttle.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

