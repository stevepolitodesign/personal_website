---
title: "Search Across Multiple Models in Rails"
date: "2021-06-26"
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/rails-search-across-multiple-models",
    },
  ]
og_image: "https://mugshotbot.com/m/zPGpwKQd"
---

In this tutorial you'll learn how to search across multiple models in Rails. Below is a demo of what we'll be building. Note how both Post and User records appear in the search. As an added bonus, we highlight the search query in the results.

![Demo](/assets/images/posts/search-across-multiple-models-in-rails/demo.png)

## Step 1: Set Up

1. Create a new Rails application.

   ```sh
   rails new rails-search-across-multiple-models
   ```

2. Generate a Post and User Scaffold.

   ```sh
   rails g scaffold Post title body:text
   rails g scaffold User name biography:text
   ```

## Step 2: Create a Model to Store Search Entries

1. Create a SearchEntry model and run migrations.

   ```sh
   rails g model SearchEntry title body:text searchable:references{polymorphic}
   rails db:migrate
   ```

2. Convert the SearchEntry model to a Delegated Type.

   ```ruby
   # app/models/search_entry.rb

   class SearchEntry < ApplicationRecord
     delegated_type :searchable, types: %w[Post User]
   end
   ```

   > **What's Going On Here?**
   >
   > - We give the model a title and a body to standardize what columns we will be able to search against. This is the actual model that will be searched.
   > - The model will connect other models through a [polymorphic association](https://guides.rubyonrails.org/association_basics.html#polymorphic-associations). This means we can make any model searchable.
   > - We use a [delegated type](https://api.rubyonrails.org/classes/ActiveRecord/DelegatedType.html) to connect the SearchEntry model with the Post and User models.

3. Create a Searchable Concern.

```ruby
# app/models/concerns/searchable.rb

module Searchable
  extend ActiveSupport::Concern

  included do
    has_one :search_entry, as: :searchable, touch: true
  end
end
```

```ruby
# app/models/post.rb

class Post < ApplicationRecord
  include Searchable
end
```

```ruby
# app/models/user.rb

class User < ApplicationRecord
  include Searchable
end
```

> **What's Going On Here?**
>
> - We create a [concern](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html) to be shared across the Post and User model. This is not required, but helps keep our code DRY.
> - The concern is simply connecting the Post and User models to the SearchEntry model. When the Post or User models are updated, the associated SearchEntry model will have its `updated_at` column updated. This is because we're calling `touch: true`. That part is not required, but helps keep things consistent between models.

## Step 3: Prevent Duplicate SearchEntry Records

1. Add a uniquness scope to the SearchEntry model.

```ruby
# app/models/search_entry.rb

class SearchEntry < ApplicationRecord
  delegated_type :searchable, types: %w[Post User]

  validates :searchable_type, uniqueness: { scope: :searchable_id }
end
```

> **What's Going On Here?**
>
> - We add a [uniqueness scope](https://guides.rubyonrails.org/active_record_validations.html#uniqueness) to prevent a Post or User from having multiple SearchEntry records associated with them. This will prevent duplicate search results.

## Step 4: Use Callbacks to Dynamically Create, Update and Destroy SearchEntry Records.

1. Add the following callbacks to the Post and User models.

```ruby
# app/models/post.rb

class Post < ApplicationRecord
  include Searchable

  after_commit :create_search_entry, on: :create
  after_commit :update_search_entry, on: :update
  after_commit :destroy_search_entry, on: :destroy

  private

  def create_search_entry
    SearchEntry.create(title: self.title, body: self.body, searchable: self)
  end

  def update_search_entry
    if self.search_entry.present?
      self.search_entry.update(title: self.title, body: self.body)
    end
  end

  def destroy_search_entry
    self.search_entry.destroy if self.search_entry.present?
  end
end
```

```ruby
# app/models/user.rb

class User < ApplicationRecord
  include Searchable

  after_commit :create_search_entry, on: :create
  after_commit :update_search_entry, on: :update
  after_commit :destroy_search_entry, on: :destroy

  private

  def create_search_entry
    SearchEntry.create(title: self.name, body: self.biography, searchable: self)
  end

  def update_search_entry
    if self.search_entry.present?
      self.search_entry.update(title: self.name, body: self.biography)
    end
  end

  def destroy_search_entry
    self.search_entry.destroy if self.search_entry.present?
  end
end
```

> **What's Going On Here?**
>
> - We use [callbacks](https://guides.rubyonrails.org/active_record_callbacks.html) to create, update and destroy an associated SearchEntry record per Post and User. This ensures that the associated SearchEntry will always be in sync with the source model.
> - We set the `title` and `body` columns on the SearchEntry to whatever values make most sense. This allows us to have full control over what will be able to be searched. Note that we can pass whatever we want into the `title` and `body` columns.

## Step 5: Create the Search Form

1. Create a SearchEntries Controller.

```sh
rails g controller SearchEntries index
```

2. Add a route for the search form and root path.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root to: "search_entries#index"
  get "search_entries/index", as: "search"
end
```

3. Build the search endpoint.

```ruby
# app/controllers/search_entries_controller.rb

class SearchEntriesController < ApplicationController
  def index
    @search_entries =
      SearchEntry.where(
        "title LIKE ? OR body LIKE ?",
        "%#{params[:query]}%",
        "%#{params[:query]}%",
      ) if params[:query]
  end
end
```

> **What's Going On Here?**
>
> - We query for any SearchEntry record that has a title or body containing the search query.
> - We add the `if params[:query]` conditional to prevent any results from being rendered until a user makes a search query. This is optional.

4. Build the search form and search partial.

```erb
# app/views/search_entries/index.html.erb

<%= form_with url: :search, method: :get do |form| %>
  <%= form.label :query, "Search for:" %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
  <%= link_to "Reset", search_path %>
<% end %>
<%= render partial: "search_entries/search_entry", collection: @search_entries %>
```

```erb
# app/views/search_entries/_search_entry.html.erb

<%= link_to polymorphic_path search_entry.searchable do %>
  <h2><%= highlight search_entry.title, params[:query] %></h2>
  <span><strong><%= search_entry.searchable_type %></strong></span>
  <p><%= highlight search_entry.body, params[:query] %></p>
  <hr/>
<% end %>
```

> **What's Going On Here?**
>
> - We create a [simple search form](https://guides.rubyonrails.org/form_helpers.html#a-generic-search-form) that will hit `search_entries#index`. The `form.text_field :query` field simply passes the correct parameter into the URL.
> - We create a simple partial to render the search result. We use the [polymorphic_path](https://api.rubyonrails.org/classes/ActionDispatch/Routing/PolymorphicRoutes.html#method-i-polymorphic_path) method to link to the correct model (Post or User).
> - We use the [highlight](https://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-highlight) method to highlight the string being searched.
