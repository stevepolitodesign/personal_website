---
title: Your chat bot needs a better rate limit strategy
excerpt: Don't let one ambitious user trigger a denial of service.
category: ["Ruby on Rails", "Artificle Intelligence"]
tags: ["Web Development", "Chat Bot"]
canonical_url: https://thoughtbot.com/blog/chat-bot-per-user-rate-limits
---

I'm on a project where we're connecting to OpenAI to build a chat bot.

Because OpenAI’s [rate limits][openai-rate-limit] are [more
complicated][complicated] than other APIs, we made sure to [proactively avoid
rate limits][proactive] by keeping track of how many tokens we're using.
However, this approach is incomplete in that it does nothing to limit an
**individual** user's usage.

A chat bot feature is unique in that it can quickly exhaust your organization's
rate limits across multiple dimensions: requests per minute (RPM) and tokens per
minute (TPM). This is because...

-   Chatting enables the user to send messages in rapid succession,
    which increases RPM.
-   Messages can be long, contain attachments, and as the conversation
    grows, so does the context window, which increases TPM.

Once a user hits the organization's limit, **everything** that uses OpenAI is
affected, and will no longer work. In the case of my project, not only does that
mean the chat bot feature would be down, but also other tools we use that
leverage OpenAI.

In short, one user can trigger a denial of service simply by using a feature as
it was intended to be used.

Fortunately, there are a few solutions to this problem.

## Our base

For the sake of this demonstration, we'll use [RubyLLM][ruby-llm], but the concepts
we'll learn apply to any implementation and platform.

```ruby
chat = RubyLLM.chat

response = chat.ask "What's a good rate limit strategy for a chat bot?"

puts response.content
```

## Rate limit messages

The first thing we can do is limit the number of messages a user can send in a
given time frame. This is known as "fixed-window rate limiting". Although Rails
ships with a [rate limit mechanism][rails-rate-limit], that won't help us when
we need to rate limit token usage. Instead, we can rely on a [cache
store][cache-store] like Redis, since its built-in [INCR][redis-incr] and
[EXPIRE][redis-expire] APIs lend themselves well to a [rate limiting
mechanism][redis-rate-limit].

```ruby
# app/models/usage.rb
class Usage
  MAX_RPM = ENV.fetch("USAGE_MAX_RPM", 10).to_i

  def initialize(user, cache_store = ActiveSupport::Cache::RedisCacheStore.new)
    @user = user
    @cache_store = cache_store
  end

  def track!
    track_rpm!
  end

  def exceeded?
    rpm_exceeded?
  end

  private

  attr_reader :user, :cache_store

  def rpm_key
    "usage:user:#{user.id}:rpm"
  end

  def track_rpm!
    cache_store.increment(rpm_key, 1, expires_in: 1.minute)
  end

  def rpm_exceeded?
    cache_store.read(rpm_key, raw: true).to_i >= MAX_RPM
  end
end

# app/models/user.rb
class User < ApplicationRecord
  def usage
    Usage.new(self)
  end
end
```

We can create a simple object that tracks user requests per minute simply by
[incrementing][rails-incrementing] the value by one for each request made,
making sure to expire the key after one minute.

Here’s how that might look when used with our chat bot:

```ruby
chat = RubyLLM.chat
user = User.last!
usage = user.usage

unless usage.exceeded?
  response = chat.ask "What's a good rate limit strategy for a chat bot?"

  usage.track!

  puts response.content
else
  # Alert user that they've exceeded their usage.
end
```

Before making a request, we check to see if the user has exhausted their
individual rate limit. If not, we make the request and track the usage.

## Limit token usage

Limiting requests is just half of the problem, since token usage is also a
metric that requires rate limiting.

We can't just [validate the length][validate-length] of the message, since
token usage doesn't map 1:1 with character length. Additionally, token
usage is also based on output tokens.

Fortunately, OpenAI returns usage data in the [response][openai-response], which
RubyLLM exposes in a [`Message`][ruby-llm-message] instance.

```diff
 class Usage
   MAX_RPM = ENV.fetch("USAGE_MAX_RPM", 10).to_i
+  MAX_TPM = ENV.fetch("USAGE_MAX_TPM", 10_000).to_i

   def initialize(user, cache_store = ActiveSupport::Cache::RedisCacheStore.new)
     @user = user
     @cache_store = cache_store
   end

-  def track!
-    track_rpm!
+  def track!(total_tokens)
+    [ track_rpm!, track_tpm!(total_tokens) ]
   end

   def exceeded?
-    rpm_exceeded?
+    rpm_exceeded? || tpm_exceeded?
   end

   private
@@ -29,4 +30,16 @@ class Usage
   def rpm_exceeded?
     cache_store.read(rpm_key, raw: true).to_i >= MAX_RPM
   end
+
+  def tpm_key
+    "usage:user:#{user.id}:tpm"
+  end
+
+  def track_tpm!(total_tokens)
+    cache_store.increment(tpm_key, total_tokens, expires_in: 1.minute)
+  end
+
+  def tpm_exceeded?
+    cache_store.read(tpm_key, raw: true).to_i >= MAX_TPM
+  end
 end
```

We can use the same pattern we used for tracking requests to track tokens.
The only difference is that we need to supply that information.

Here's how that would look in our chat bot:

```diff
 unless usage.exceeded?
   response = chat.ask "What's a good rate limit strategy for a chat bot?"

-  usage.track!
+  tokens = response.tokens
+  total_tokens = tokens.input + tokens.output + tokens.thinking
+
+  usage.track!(total_tokens)

   puts response.content
 else
```

After making a request, we extract
the token usage from the response, and pass it to our `Usage` instance
to be used in the next request.

## Calculating per-user rate limits

Since the rate limits set by OpenAI and other providers are at the
organization level, how might we evenly distribute those values on a per-user
basis?

A simple approach suitable for most early-stage products would be to divide
the organization limit by the expected concurrent users. In order to ensure we
account for unexpected spikes in traffic, we can add in a buffer.

```
Per-user limit = (Organization limit × buffer) / Expected concurrent users
```

Below is what that looks like using the values in this demonstration.

| Metric | Org Limit | Concurrent Users | Buffer | Per-user Limit     |
| ------ | --------- | ---------------- | ------ | ------------------ |
| RPM    | 125       | 10               | 0.8    | (125 \* 0.8) / 10       |
| TPM    | 125,000   | 10               | 0.8    | (125,000 \* 0.8) / 10   |

## Additional considerations

The core problem is that a chat bot is inherently expensive. If we stick to
these numbers, we're constrained to 10 concurrent users, which feels pretty
limited, even for an early-stage product.

One solution is to queue the requests rather than reject them, which might look
something like this:

```ruby
class ProcessPromptJob < ApplicationJob
  queue_as :default

  MAX_ATTEMPTS = 2

  rescue_from(Usage::RateLimitExhaustedError) do
    if executions < MAX_ATTEMPTS
      retry_job wait: 15.seconds
    else
      # Broadcast failure message to user
    end
  end

  def perform(user, prompt)
    raise Usage::RateLimitExhaustedError if user.usage.exceeded?

    chat = RubyLLM.chat

    response = chat.ask(prompt)

    tokens = response.tokens
    total_tokens = tokens.input + tokens.output + tokens.thinking

    user.usage.track!(total_tokens)

    # Broadcast LLM response to user
  end
end
```

```diff
 class Usage
+  class RateLimitExhaustedError < StandardError; end
+
   MAX_RPM = ENV.fetch("USAGE_MAX_RPM", 10).to_i
   MAX_TPM = ENV.fetch("USAGE_MAX_TPM", 10_000).to_i

```

The flow would be something like this:

```
User sends message
  └─▶ Show loading state
        └─▶ Enqueue background job
              └─▶ Rate limit exceeded?
                    ├─ No  ──▶ Process request ──▶ Broadcast response
                    └─ Yes ──▶ Wait 15 seconds
                                 └─▶ Rate limit exceeded?
                                       ├─ No  ──▶ Process request ──▶ Broadcast response
                                       └─ Yes ──▶ Broadcast failure
```

## Wrapping up

Limiting a user's application usage is not a new problem, but it's more relevant
today with the rise in chat bot features.

The examples above highlight simple solutions, but they're just a start — a more
nuanced approach will likely be needed.

For example, if a user hits their limit, do you attempt to upsell them? Do you
flat out block them? Or, should you fall back to a cheaper model? Maybe a
combination of these suggestions?

Regardless, these decisions should involve stakeholders such as designers and
the product team.

[cache-store]: https://guides.rubyonrails.org/caching_with_rails.html#other-cache-stores
[complicated]: https://developers.openai.com/api/docs/guides/rate-limits#how-do-these-rate-limits-work
[incrementing]: https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html#method-i-increment
[openai-rate-limit]: https://developers.openai.com/api/docs/guides/rate-limits#rate-limits-in-headers
[openai-response]: https://developers.openai.com/api/reference/resources/responses/methods/create
[proactive]: https://thoughtbot.com/blog/openai-rate-limits#avoid-rate-limits-by-being-proactive
[rails-incrementing]: https://api.rubyonrails.org/v8.1.2/classes/ActiveSupport/Cache/RedisCacheStore.html#method-i-increment
[rails-rate-limit]: https://api.rubyonrails.org/classes/ActionController/RateLimiting/ClassMethods.html#method-i-rate_limit
[redis-expire]: https://redis.io/docs/latest/commands/expire//
[redis-incr]: https://redis.io/docs/latest/commands/incr/
[redis-rate-limit]: https://redis.io/glossary/rate-limiting/
[ruby-llm-message]: https://www.rubydoc.info/gems/ruby_llm/RubyLLM/Message
[ruby-llm]: https://rubyllm.com
[validate-length]: https://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html#method-i-validates_length_of
