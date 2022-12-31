---
title: "Obfuscate Numerical IDs in Rails"
categories: ["Ruby on Rails"]
resources: [
  {
    title: "SecureRandom.urlsafe_base64",
    url: "https://ruby-doc.org/stdlib-2.5.1/libdoc/securerandom/rdoc/Random/Formatter.html#method-i-urlsafe_base64"
  },
  {
    title: "Using :if and :unless with a Proc",
    url: "https://guides.rubyonrails.org/active_record_callbacks.html#using-if-and-unless-with-a-proc"
  },
  {
    title: "friendly_id Gem",
    url: "https://github.com/norman/friendly_id#usage"
  },
  {
    title: "ActiveRecord and FriendlyId: slug not generated when field set with before_validation callback",
    url: "https://mensfeld.pl/2015/01/activerecord-and-friendlyid-slug-not-generated-when-field-set-with-before_validation-callback/"
  }
]
date: 2020-03-22
---

By default, Rails displays the record's `ID` in the URL (e.g. `http://localhost:3000/articles/1`). Although there is nothing inherently wrong with this approach, sometimes it's helpful to obfuscate the record's `ID` (e.g. `http://localhost:3000/articles/xb3mm6k`). In this tutorial I will show you how to obfuscate numerical `IDs` in Rails.

{% youtube "https://www.youtube.com/embed/gOF7bqKJ_nY" %}

## Step 1. Add a Hashid Column to Your Model

In order to obfuscate our record's `IDs` we'll first need to add a column to our model to store a random value. We can call this column anything, but let's call it `hashid`.

1. `rails g migration add_hashid_to_articles hashid:string`
2. `rails db:migrate`

## Step 2. Set the Value of the Hashid in a Callback

Next we need to programmatically set the value of the `hashid` column. There are many ways to achieve this, but I like using [SecureRandom.urlsafe_base64](https://ruby-doc.org/stdlib-2.5.1/libdoc/securerandom/rdoc/Random/Formatter.html#method-i-urlsafe_base64) in combination with a [before_validation](https://guides.rubyonrails.org/active_record_callbacks.html#available-callbacks) callback.

> SecureRandom.urlsafe_base64 generates a random URL-safe base64 string.

1.

```ruby
class Article < ApplicationRecord

    before_validation :set_hashid, prepend: true, if: Proc.new{ |article| article.hashid.nil? }

    private

        def set_hashid
            self.hashid = SecureRandom.urlsafe_base64(5)
        end
end
```

- First we create a private `set_hashid` method that will set the `hashid` to the return value of `SecureRandom.urlsafe_base64(5)`.
- Then we call this method with a `before_validation` callback.
  - We add `prepend: true` to ensure this callback is called before `friendly_id` set's the `slug` (note that we have not yet installed `friendly_id`).
  - We use a [:if with a Proc](https://guides.rubyonrails.org/active_record_callbacks.html#using-if-and-unless-with-a-proc) to ensure that the `set_hashid` method is only called if the record does not yet have a `hashid`. This ensures that the `hashid` does not change each time a record is updated.


## Step 3. Install and Configure friendly_id

Now that we are programmatically assigning a `hashid` to our model, we need to use that value in the URL. Luckily the [friendly_id](https://github.com/norman/friendly_id) makes this easy.



1. Add `gem 'friendly_id', '~> 5.3'` to your `Gemfile`.
2. Run the following commands.

```
rails g migration add_slug_to_articles slug:uniq
rails generate friendly_id
rails db:migrate
```

3. Next, update your model so it can use `friendly_id` to set a `slug`

```ruby{2-3}
class Article < ApplicationRecord
    extend FriendlyId
    friendly_id :hashid, use: :slugged

    before_validation :set_hashid, prepend: true, if: Proc.new{ |article| article.hashid.nil? }

    private

        def set_hashid
            self.hashid = SecureRandom.urlsafe_base64(5)
        end
end
```

4. Then update your controller to use `friendly` by replacing `Model.find` with `Model.friendly.find`

```ruby{6}
class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  ...
  private
    def set_article
      @article = Article.friendly.find(params[:id])
    end
end
```

5. Finally, update any existing records by opening the [rails console](https://guides.rubyonrails.org/command_line.html#rails-console) and running `Article.find_each(&:save)`

## Conclusion and Next Steps

One important thing to note is that `SecureRandom.urlsafe_base64` does not guarantee a unique value. This means that there's a chance multiple records could have the same value for the `hashid`. Fortunately `fiendly_id` accounts for any conflicting slugs by appending a [UUID](https://ruby-doc.org/stdlib-2.5.1/libdoc/securerandom/rdoc/SecureRandom.html) to the `slug`. If you want more control over the what is appended to the url, you can use [candidates](https://norman.github.io/friendly_id/).
