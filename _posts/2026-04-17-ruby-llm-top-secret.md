---
title: PII filtering for RubyLLM with Top Secret
excerpt: Automatically filter sensitive information from your RubyLLM conversations before it reaches third-party providers.
category: ["Ruby"]
tags: ["Artificial Intelligence", "Security"]
canonical_url: https://thoughtbot.com/blog/ruby-llm-top-secret
---

If you're building LLM-powered features in a regulated industry, sending
unfiltered PII to a third-party provider isn't just risky, it may violate
compliance requirements like HIPAA or GDPR.

That's why we originally built [Top Secret][top-secret]. However, when we first
released it, [RubyLLM][ruby-llm] was still in its early days, and I found I was
working with provider APIs directly, such as [Ruby OpenAI][ruby-openai] or
[OpenAI Ruby][openai-ruby]. This meant I needed to manually orchestrate the
filtering and restoration process, which looked something like this:

```ruby
require "openai"
require "top_secret"

openai = OpenAI::Client.new

original_messages = [
  "Ralph lives in Boston.",
  "You can reach them at ralph@thoughtbot.com or 877-976-2687"
]

# Filter all messages
result = TopSecret::Text.filter_all(original_messages)
user_messages = result.items.map { {role: "user", content: it.output} }

messages = [*user_messages]

chat_completion = openai.chat.completions.create(messages:, model: :"gpt-5")
response = chat_completion.choices.last.message.content

# Restore the response from the mapping
mapping = result.mapping
restored_response = TopSecret::FilteredText.restore(response, mapping:).output
```

Even with RubyLLM, there was no way to filter and restore conversation
history, since `Chat#ask` handles the message life cycle internally.

## Enter RubyLLM::TopSecret

The introduction of [RubyLLM::TopSecret][ruby-llm-top-secret] aims to make
filtering sensitive information from RubyLLM chats as simple as possible. All
you need to do is wrap your existing in-memory chats with
`RubyLLM::TopSecret.with_filtering`:

```ruby
RubyLLM::TopSecret.with_filtering do
  chat = RubyLLM.chat
  response = chat.ask("My name is Ralph and my email is ralph@thoughtbot.com")

  # The provider receives: "My name is [PERSON_1] and my email is [EMAIL_1]"
  # The response comes back with placeholders restored:
  puts response.content
  # => "Nice to meet you, Ralph!"
end
```

Working with [ActiveRecord-backed chats][rails-integration] is even easier. All
you need to do is add the `acts_as_filtered_chat` class macro, and the gem will
take care of the rest.

```ruby
class Chat < ApplicationRecord
  acts_as_chat
  acts_as_filtered_chat
end
```

If you want more granular control, you can simply pass an `if:`
condition. For example, you might only need to filter customer-facing
chats that process health data, but not internal admin conversations. A
simple way to model this would be to add a `filtered` boolean column to
the `chats` table:

```ruby
class Chat < ApplicationRecord
  acts_as_chat
  acts_as_filtered_chat if: :filtered?
end
```

In either case, the goal is to create an opt-in approach that just works. If you want to see it in action, check out this [live demo][video].

If you're interested in exploring the gem yourself, follow the
[installation][install] guide and refer to the [usage][usage] section for
a more detailed overview.

[install]: https://github.com/thoughtbot/ruby_llm-top_secret?tab=readme-ov-file#installation
[openai-ruby]: https://github.com/openai/openai-ruby
[rails-integration]: https://rubyllm.com/rails/
[ruby-llm-top-secret]: https://github.com/thoughtbot/ruby_llm-top_secret
[ruby-llm]: https://rubyllm.com
[ruby-openai]: https://github.com/alexrudall/ruby-openai
[top-secret]: https://thoughtbot.com/blog/top-secret
[usage]: https://github.com/thoughtbot/ruby_llm-top_secret?tab=readme-ov-file#usage
[video]: https://youtu.be/gYz78UYYoLU
