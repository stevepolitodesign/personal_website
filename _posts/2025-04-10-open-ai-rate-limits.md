---
title: How to respect OpenAI's rate limits in Rails
excerpt: As it turns out, OpenAI's rate limits are a little more complicated than other APIs.
category: ["Ruby on Rails"]
tags: ["Artificial Intelligence"]
canonical_url: https://thoughtbot.com/blog/openai-rate-limits
---

I'm on a Rails project using OpenAI. We're sending over large amounts of text to
provide as much context as possible, and recently ran into issues with
rate limiting.

As it turns out, OpenAI's [rate limits][] are a little more complicated than
other APIs.

> Rate limits are measured in five ways: RPM (requests per minute), RPD
> (requests per day), TPM (tokens per minute), TPD (tokens per day), and IPM
> (images per minute). Rate limits can be hit across any of the options
> depending on what occurs first.

In our case, we were hitting our **TPM** (tokens per minute) rate limit.

Regardless of whether a rate limit is exceeded, OpenAI will return the following
[headers][headers].

```
x-ratelimit-reset-requests: 1s
x-ratelimit-reset-tokens: 6m0s
```

It should be noted that these headers represent the amount of time that needs to
pass before the rate limit returns to its initial state.

At the time of this writing, OpenAI does not have a first-party Ruby library,
but the community has gravitated towards [ruby-openai][], which is what our
project is using. When a rate limit is hit, it raises
`Faraday::TooManyRequestsError`, which gives us access to those headers via
[`#response_headers`][].

Because OpenAI will return two headers (one for requests per minute and one for
tokens per minute), we play it safe and wait based on the greater of the two
values.

Rather than roll our own script to parse the header values, we can use [Chronic
Duration][] to do this for us. We can then define our own custom error class in
an initializer to build the wait value for us.

In order to use this value, we need to leverage [`#rescue_from`][] in
combination with [`#retry_job`][]. This is because we need to set the `wait`
value dynamically based on the headers, and [`#retry_on`][] does not provide a
way to do this.

Below is a distilled example.

```ruby
# app/jobs/send_prompt_job.rb
class SendPromptJob < ApplicationJob
  queue_as :default

  MAX_ATTEMPTS = 2

  rescue_from OpenAI::RateLimitError do |error|
    if executions < MAX_ATTEMPTS
      backoff = Backoff.polynomially_longer(executions:)

      retry_job wait: error.wait.seconds + backoff
    else
      Rails.logger.info "Exhausted attempts"
    end
  end

  def perform()
    OpenAI::Client.new.chat(...)
  rescue Faraday::TooManyRequestsError => error
    raise OpenAI::RateLimitError.new(error)
  end
end

# lib/backoff.rb
class Backoff
  DEFAULT_JITTER = 0.15

  def self.polynomially_longer(executions:, jitter: DEFAULT_JITTER)
    ((executions**4) + (Kernel.rand * (executions**4) * jitter)) + 2
  end
end

# config/initializers/openai.rb
module OpenAI
  class RateLimitError < StandardError
    attr_reader :reset_requests_in_seconds, :reset_tokens_in_seconds

    def initialize(faraday_error)
      headers = faraday_error.response_headers&.with_indifferent_access || {}

      @reset_requests_in_seconds = headers.fetch("x-ratelimit-reset-requests", "0s")
      @reset_tokens_in_seconds = headers.fetch("x-ratelimit-reset-tokens", "0s")

      super("The API has hit the rate limit")
    end

    def wait
      [
        parse_duration(reset_requests_in_seconds),
        parse_duration(reset_tokens_in_seconds)
      ].max
    end

    private

    def parse_duration(value)
      ChronicDuration.parse(value) || 0
    end
  end
end
```

Since we can't leverage `retry_on`, we need to ensure we eventually stop
retrying the job if it continues to fail.

```ruby
executions < MAX_ATTEMPTS
```

Additionally, you'll also note that we add a "backoff" mechanism per OpenAI's
[recommendation][].

```ruby
backoff = Backoff.polynomially_longer(executions:)

retry_job wait: error.wait.seconds + backoff
```

## Avoid rate limits by being proactive

We took a reactive approach to the problem, but I do want to highlight that
there's an opportunity to be proactive by examining the [headers][] that return
the amount of remaining requests or tokens that are permitted before exhausting
the rate limit.

```
x-ratelimit-remaining-requests
x-ratelimit-remaining-tokens
```

Unfortunately, `ruby-openai` [does not return response headers][438], but there
is a workaround. You can create a custom Faraday middleware, and pass it to the
client in a block.

```ruby
class ExtractRateLimitHeaders< Faraday::Middleware
  def on_complete(env)
    # Store these values somewhere
    remaining_requests = env.response_headers["x-ratelimit-remaining-requests"]
    remaining_tokens = env.response_headers["x-ratelimit-remaining-tokens"]
  end
end

client = OpenAI::Client.new do |faraday|
  faraday.use ExtractRateLimitHeaders
end
```

You could then use this information to reduce the number of tokens you plan on
sending to OpenAI by comparing its size with `remaining_tokens`. Or, if you're
keeping track of how many requests you're making, you could compare that value
with `remaining_requests`.

```ruby
# Ensure you're within the request and/or token limit before making a request
if (current_requests < remaining_requests && current_tokens < remaining_tokens)
  client.chat(...)
end
```

Alternatively, you could temporarily switch to a model with higher token and
request limits, or temporarily reduce the amount of tokens sent in the request.

[rate limits]: https://platform.openai.com/docs/guides/rate-limits?context=tier-free#rate-limits-in-headers
[headers]: https://platform.openai.com/docs/guides/rate-limits#rate-limits-in-headers
[ruby-openai]: https://github.com/alexrudall/ruby-openai
[`#response_headers`]: https://www.rubydoc.info/gems/faraday/Faraday%2FError:response_headers
[`#rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`#retry_job`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions.html#method-i-retry_job
[`#retry_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
[Chronic Duration]: https://github.com/henrypoydar/chronic_duration
[438]: https://github.com/alexrudall/ruby-openai/issues/438
[recommendation]: https://cookbook.openai.com/examples/how_to_handle_rate_limits#retrying-with-exponential-backoff
