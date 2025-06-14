---
title: Prevent logging sensitive information in Rails, and beyond
excerpt: The Rails defaults are a good foundation, but it's still your responsibility to filter sensitive information from logs when using external APIs, services, and tools.
category: ["Ruby on Rails"]
tags: ["Tutorial", "Security"]
canonical_url: https://thoughtbot.com/blog/parameter-filtering
---

By default, Rails [filters out sensitive request parameters][1] from your log
files. I've found the [default values][2] are a good foundation, and account for
_almost_ all use cases.

```ruby
# config/initializers/filter_parameter_logging.rb

Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc
]
```

If a request is made that contains a parameter that partially matches any of
these values, it will be filtered.

```
Parameters: {"authenticity_token"=>"[FILTERED]", "email_address"=>"[FILTERED]", "password"=>"[FILTERED]", "commit"=>"Sign in"}
```

It also [filters the associated attributes][3].

```ruby
<User:0x000000011f735030
 id: 980190962,
 email_address: "[FILTERED]",
 password_digest: "[FILTERED]",
 created_at: "2025-04-23 13:59:46.324377000 +0000",
 updated_at: "2025-04-23 13:59:46.324377000 +0000">
```

[1]: https://guides.rubyonrails.org/action_controller_advanced_topics.html#parameters-filtering
[2]: https://guides.rubyonrails.org/configuring.html#config-filter-parameters
[3]: https://api.rubyonrails.org/classes/ActiveRecord/Core/ClassMethods.html#method-i-filter_attributes

## Don't just filter sensitive information, encrypt it

There's a case to be made that you should rarely need to update the default
list. This is because if you plan on storing anything worth filtering, it should
be [encrypted][4].

```ruby
class User < ApplicationRecord
  encrypts :phone_number
end
```

Fortunately, Rails has accounted for this by [automatically filtering encrypted
attributes][5].

Note how the `phone_number` is filtered when logging internal requests.

```
Parameters: {"authenticity_token"=>"[FILTERED]", "user"=>{"email_address"=>"[FILTERED]", "phone_number"=>"[FILTERED]", "password_digest"=>"[FILTERED]"}, "commit"=>"Create User"}
```

It's also filtered when inspecting an object.

```ruby
<User:0x0000000121282608
 id: 980190962,
 email_address: "[FILTERED]",
 password_digest: "[FILTERED]",
 created_at: "2025-04-23 14:10:49.414784000 +0000",
 updated_at: "2025-04-23 14:10:49.414784000 +0000",
 phone_number: "[FILTERED]">
```

[4]: https://guides.rubyonrails.org/active_record_encryption.html
[5]: https://guides.rubyonrails.org/active_record_encryption.html#filtering-params-named-as-encrypted-columns

## Filter sensitive information from external network requests

Just because Rails provides a good foundation doesn't mean it accounts for
everything.

For example, if you're using Faraday, it's your responsibility to [filter
sensitive information][6] when logging requests. This does not happen by
default.

```ruby
conn = Faraday.new(url: "http://httpbingo.org") do |builder|
  builder.request :json
  builder.response :json
  builder.response :raise_error
  builder.response :logger, nil, {
    headers: true,
    bodies: true,
    errors: true
  }
end

conn.get("get", api_key: "secret")
conn.post("anything", user: User.last!.as_json)
```

We're exposing the `api_key` when logging both the request and the
response when making a `GET` request.

```
INFO -- : request: GET http://httpbingo.org/get?api_key=secret
INFO -- : response: {
  "args": {
    "api_key": [
      "secret"
    ]
  },
  "url": "http://httpbingo.org/get?api_key=secret"
}
```

We're also exposing all the sensitive attributes on `user`, even though those
are filtered internally.

```
INFO -- : request: POST http://httpbingo.org/anything
INFO -- : response: {
  "data": "{\"user\":{\"id\":980190962,\"email_address\":\"one@example.com\",\"password_digest\":\"$2a$12$Qo1yNHtJ58InjxM2d3895emekpMVpEzwLTtMJ/piHeDet0oePuKne\",\"created_at\":\"2025-04-23T14:10:49.414Z\",\"updated_at\":\"2025-04-23T14:10:49.414Z\",\"phone_number\":\"555-555-5555\"}}",
  "json": {
    "user": {
      "created_at": "2025-04-23T14:10:49.414Z",
      "email_address": "one@example.com",
      "id": 980190962,
      "password_digest": "$2a$12$Qo1yNHtJ58InjxM2d3895emekpMVpEzwLTtMJ/piHeDet0oePuKne",
      "phone_number": "555-555-5555",
      "updated_at": "2025-04-23T14:10:49.414Z"
    }
  }
}
```

Faraday offers an API for [filtering sensitive information][6], but using it
would mean you would need to duplicate efforts.

Fortunately, we can create a [custom formatter][7] to re-use our Rails
configuration.

```ruby
class ApplicationFormatter < Faraday::Logging::Formatter
  def request(env)
    info("Request") { log_url(env.url) }
    info("Request") { log_body(env.body) } if env.body && log_body?
  end

  def response(env)
    info("Response") { log_url(env.url) }
    info("Response") { log_body(env.body) } if env.body && log_body?
  end

  private

  # Re-uses existing configuration from config/initializers/filter_parameter_logging.rb  
  def filter_parameters
    @filter_parameters ||= Rails.configuration.filter_parameters
  end

  # Filters parameters
  def parameter_filter(**options)
    ActiveSupport::ParameterFilter.new(filter_parameters, **options)
  end

  def parse_json(json)
    JSON.parse(json, object_class: HashWithIndifferentAccess)
  end

  def log_body?
    @options[:bodies]
  end

  def log_body(body)
    result = walk(body)

    parameter_filter.filter(result).pretty_inspect
  end

  def log_url(url)
    filtered_url = filter_url(url)

    filtered_url.to_s
  end

  def filter_url(url)
    return url if url.query.nil?

    params = URI.decode_www_form(url.query).to_h
    filtered_params = parameter_filter(mask: "FILTERED").filter(params)
    url.query = URI.encode_www_form(filtered_params)
  end

  def walk(obj)
    case obj
    when Hash
      obj.transform_values { walk(_1) }
    when Array
      obj.map { walk(_1) }
    when String
      parse_json(obj)
    else
      obj
    end
  rescue JSON::ParserError
    obj
  end
end
```

```diff
--- a/lib/faraday.rb
+++ b/lib/faraday.rb
-   errors: true
+   errors: true,
+   formatter: ApplicationFormatter
+ }
end
```

Now the `api_key` is filtered when logging both the response and the request.
This is because we're already filtering against partial matches on `_key`.

```
INFO -- Request: api_key=FILTERED
INFO -- Response: {"args"=>{"api_key"=>"FILTERED"},
 "url"=>"http://httpbingo.org/get?api_key=FILTERED"}
```

We're also no longer exposing all the sensitive attributes on `user`.

```
INFO -- Request: http://httpbingo.org/anything
INFO -- Response: {"args"=>{},
 "data"=>
  {"user"=>
    {"id"=>980190962,
     "email_address"=>"[FILTERED]",
     "password_digest"=>"[FILTERED]",
     "created_at"=>"2025-04-23T14:10:49.414Z",
     "updated_at"=>"2025-04-23T14:10:49.414Z",
     "phone_number"=>"[FILTERED]"}},
 "json"=>
  {"user"=>
    {"created_at"=>"2025-04-23T14:10:49.414Z",
     "email_address"=>"[FILTERED]",
     "id"=>980190962,
     "password_digest"=>"[FILTERED]",
     "phone_number"=>"[FILTERED]",
     "updated_at"=>"2025-04-23T14:10:49.414Z"}}}
```

[6]: https://lostisland.github.io/faraday/#/middleware/included/logging?id=filter-sensitive-information
[7]: https://lostisland.github.io/faraday/#/middleware/included/logging?id=customize-the-formatter

## Creating an allow list

Let's imagine we add a `name` column to the `users` table. Depending on the
application, this could be considered sensitive information, but may not warrant
encryption. 

In this case, you'd need to remember to update
`config/initializers/filter_parameter_logging.rb`. In my experience, this is
almost always forgotten. Instead, what we want is an [allow list][8].

The idea is that you'd filter everything except timestamps and IDs.

```ruby
# config/initializers/filter_parameter_logging.rb

Rails.application.config.filter_parameters += [
  lambda { |k, v| v.replace("[FILTERED]") unless k.match?(/\A(id|.*_id|.*_at|.*_on)\z/) }
]
```

This can be confirmed when inspecting a `user`. Note how the `name` is also
filtered.

```ruby
#<User:0x00000001306db560
 id: 980190962,
 email_address: [FILTERED],
 password_digest: [FILTERED],
 created_at: "2025-04-23 14:10:49.414784000 +0000",
 updated_at: "2025-06-06 11:45:52.243742000 +0000",
 phone_number: "[FILTERED]",
 name: [FILTERED]>
```

However, this approach might be a little too aggressive, since it filters
**everything**. Notice how the `commit` parameter is now filtered from our requests.

```
Parameters: {"authenticity_token"=>"[FILTERED]", "user"=>{"email_address"=>"[FILTERED]", "phone_number"=>"[FILTERED]", "password_digest"=>"[FILTERED]"}, "commit"=>"[FILTERED]"}
```

This change also affects our Faraday logging.

Now the entire `url` is filtered, instead of just the `api_key` parameter.

```
INFO -- Request: api_key=%5BFILTERED%5D
INFO -- Response: {"args"=>{"api_key"=>["[FILTERED]"]},
 "url"=>"[FILTERED]"}
```

And the entire `data` hash is filtered, instead of just the relevant attributes.

```
INFO -- Request: http://httpbingo.org/anything
INFO -- Response: {"args"=>{},
 "data"=>"[FILTERED]",
 "json"=>
  {"user"=>
    {"created_at"=>"2025-04-23T14:10:49.414Z",
     "email_address"=>"[FILTERED]",
     "id"=>980190962,
     "name"=>"[FILTERED]",
     "password_digest"=>"[FILTERED]",
     "phone_number"=>"[FILTERED]",
     "updated_at"=>"2025-06-06T11:45:52.243Z"}}}
```

[8]: https://github.com/rails/rails/pull/45545

Depending on your team's security requirements, this might be desirable, but
it can create a poor debugging experience.

## Wrapping Up

The Rails defaults are a good foundation, and will serve you well. If you need
to store sensitive information, make sure to encrypt it. This not only filters
it from logs, but also keeps the data secure in the database.

All that aside, it's still **your** responsibility to filter sensitive information
from logs when using external APIs, services, and tools.

Finally, using an Allow List might be a better option for applications that need
to adhere to strict compliance measures, such as Healthcare.
