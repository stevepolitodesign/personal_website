---
title: Introducing Top Secret
exchange: Automatically filter sensitive information before sending it to external services or APIs, such as chatbots and LLMs.
category: ["Ruby"]
tags: ["Artificial Intelligence", "Security"]
canonical_url: https://thoughtbot.com/blog/top-secret
---

We've written about how to [prevent logging sensitive information when making
network requests][1], but that approach only works if you're dealing with
parameters.

What happens when you're dealing with free text? Filtering the entire string may
not be an option if an external API needs to process the value. Think chatbots or LLMs.

You could use a regex to filter sensitive information (such as credit card
numbers or emails), but that won't capture everything, since not all sensitive
information can be captured with a regex.

Fortunately, [named-entity recognition][2] (NER) can be used to identify and
classify real-world objects, such as a person, or location. Tools like [MITIE
Ruby][3] make interfacing with NER models trivial.

By using a combination of regex patterns and NER entities, [Top Secret][4]
effectively filters sensitive information from free text—here are some
real-world examples.

If you want to see [Top Secret][4] in action, you might enjoy this [live
stream][11]. Otherwise, see the examples below.

## Working with LLMs

It's not uncommon to send user data to chatbots. Since the data might be
free-form, we should be diligent about filtering it using the approach mentioned
above.

However, it's likely we'll want to "restore" the filtered values when returning
a response from the chatbot. [Top Secret][4] returns a [mapping][5] that would
allow for this.

You'd likely want to provide [instructions][6] in the request.

```ruby
instructions = <<~TEXT
  I'm going to send filtered information to you in the form of free text.
  If you need to refer to the filtered information in a response, just reference it by the filter.
TEXT
```

The exchange might look something like this.

1. Caller sends filtered text

    ```ruby
    result = TopSecret::Text.filter("Ralph lives in Boston.")

    # Send this to the API
    result.output # => [PERSON_1] lives in [LOCATION_1].

    # Save the mapping to "restore" response
    mapping = result.mapping # => { PERSON_1: "Ralph", LOCATION_1: "Boston" }
    ```

2. API responds with filter

    ```
    "Hi [PERSON_1]! How is the weather in [LOCATION_1] today?"
    ```

3. Caller can "restore" from the mapping

    ```ruby
    response = "Hi [PERSON_1]! How is the weather in [LOCATION_1] today?"

    # Restore the response from the mapping
    result = TopSecret::FilteredText.restore(response, mapping: mapping)

    result.output
    # => Hi Ralph! How is the weather in Boston today?
    ```

### Filtering conversation history

When working with [conversation state][7] you should filter **every** message
before including it in the request. This ensures no sensitive data slips through
from previous messages. Here's what that might look like.

```ruby
require "openai"
require "top_secret"

openai = OpenAI::Client.new(
  api_key: Rails.application.credentials.openai.api_key!
)

original_messages = [
  "Ralph lives in Boston.",
  "You can reach them at ralph@thoughtbot.com or 877-976-2687"
]

# Filter all messages
result = TopSecret::Text.filter_all(original_messages)
filtered_messages = result.items.map(&:output)

user_messages = filtered_messages.map { {role: "user", content: it} }

# Instruct LLM how to handle filtered messages
instructions = <<~TEXT
  I'm going to send filtered information to you in the form of free text.
  If you need to refer to the filtered information in a response, just reference it by the filter.
TEXT

messages = [
  {role: "system", content: instructions},
  *user_messages
]

chat_completion = openai.chat.completions.create(messages:, model: :"gpt-5")
response = chat_completion.choices.last.message.content

# Restore the response from the mapping
mapping = result.mapping
restored_response = TopSecret::FilteredText.restore(response, mapping:).output

puts(restored_response)
```

## Prevent storing sensitive information with validations

Top Secret can also be used as a validation tool to prevent storing sensitive
information in your database.

```ruby
class Message < ApplicationRecord
  validate :content_cannot_contain_sensitive_information

  private

  def content_cannot_contain_sensitive_information
    result = TopSecret::Text.filter(content)
    return if result.mapping.empty?

    errors.add(:content, "contains the following sensitive information #{result.mapping.values.to_sentence}")
  end
end
```

If the validation is too strict, you can [override][9] or [disable][10] any of
the filters as needed.

```diff
--- a/app/models/message.rb
+++ b/app/models/message.rb
@@ -4,7 +4,7 @@ class Message < ApplicationRecord
   private

   def content_cannot_contain_sensitive_information
-    result = TopSecret::Text.filter(content)
+    result = TopSecret::Text.filter(content, people_filter: nil, location_filter: nil)
     return if result.mapping.empty?

     errors.add(:content, "contains the following sensitive information #{result.mapping.values.to_sentence}")
```

## Wrapping up

It's our responsibility to protect user data. This is more important than ever
given the rise in popularity of chatbots and LLMs. Tools like [Top Secret][4] aim to
reduce this burden.

[1]: https://thoughtbot.com/blog/parameter-filtering#filter-sensitive-information-from-external-network-requests
[2]: https://en.wikipedia.org/wiki/Named-entity_recognition
[3]: https://github.com/ankane/mitie-ruby
[4]: https://github.com/thoughtbot/top_secret
[5]: https://github.com/thoughtbot/top_secret?tab=readme-ov-file#usage
[6]: https://platform.openai.com/docs/guides/text#message-roles-and-instruction-following
[7]: https://platform.openai.com/docs/guides/conversation-state
[8]: https://guides.rubyonrails.org/active_record_validations.html
[9]: https://github.com/thoughtbot/top_secret#overriding-the-default-filters
[10]: https://github.com/thoughtbot/top_secret#disabling-a-default-filter
[11]: https://www.youtube.com/live/m2UIpTaIZ8o?si=EzEkWHlNQJORVgSG&t=120
