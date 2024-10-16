---
title: Build a (better) search form in Rails with Active Model
excerpt: Harness the power of Active Model to supercharge your search forms.
category: ["Ruby on Rails"]
tags: ["Tutorial"]
canonical_url: https://thoughtbot.com/blog/rails-search-form-tutorial
---

I recently had the opportunity to refactor a custom search form on a client
project, and wanted to share some highlights through a distilled example.

## Our base

We'll start with all logic placed in the controller and view.

```ruby
def index
  @posts = sort_posts(Post.all).then { filter_posts(_1) }
end

private

  def sort_posts(scope)
    if (order = params.dig(:query, :sort))
      column, direction = order.split(" ")

      if column.presence_in(%w[title created_at]) && direction.presence_in(%w[asc desc])
        scope.order("#{column} #{direction}")
      else
        []
      end
    else
      scope.order(created_at: :desc)
    end
  end

  def filter_posts(scope)
    filter_by_title_or_body(scope)
      .then { filter_by_status(_1) }
      .then { filter_by_author(_1) }
  end

  def filter_by_title_or_body(scope)
    if (title_or_body = params.dig(:query, :title_or_body_contains).presence)
      scope.where("title LIKE ? or body LIKE ?", "%#{title_or_body}%", "%#{title_or_body}%")
    else
      scope
    end
  end

  def filter_by_status(scope)
    if (status = params.dig(:query, :status_in)&.compact_blank&.presence)
      scope.where(status:)
    else
      scope
    end
  end

  def filter_by_author(scope)
    if (author_id = params.dig(:query, :author_id_eq).presence)
      scope.where(author_id:)
    else
      scope
    end
  end
```

Note that the controller is responsible for validating the parameters to ensure
they aren't tampered with.

```ruby
if column.presence_in(%w[title created_at]) && direction.presence_in(%w[asc desc])
```

It also sets default sort values.

```ruby
if (order = params.dig(:query, :sort))
  # ..
else
  scope.order(created_at: :desc)
end
```

Now let's take a look at the corresponding form:

```erb
<h1>Posts</h1>

<%= form_with scope: :query, url: posts_path, method: :get do |form| %>
  <div>
    <%= form.label :title_or_body_contains, "Title or body contains" %>
    <%= form.search_field :title_or_body_contains, value: params.dig(:query, :title_or_body_contains) %>
  </div>

  <div>
    <%= form.label :sort, "Sort by" %>
    <%= form.select :sort, options_for_select(
      [
        ["Title - A to Z", "title asc"],
        ["Title - Z to A", "title desc"],
        ["Created At - Newest to Oldest", "created_at desc"],
        ["Created At - Oldest to Newest", "created_at asc"]
      ], params.dig(:query, :sort) || "created_at desc"
    ) %>
  </div>

  <div>
    <%= form.label :author_id_eq, "Authored by" %>
    <%= form.select :author_id_eq, options_from_collection_for_select(Author.all, "id", "name", params.dig(:query, :author_id_eq).to_i), {prompt: "Any"}  %>
  </div>

  <%= field_set_tag "Status" do %>
    <%= form.collection_check_boxes(:status_in, Post.statuses.keys, :to_s, :capitalize) do |builder| %>
      <%= builder.label { builder.check_box(checked: params.dig(:query, :status_in)&.include?(builder.value)) + builder.text } %>
    <% end %>
  <% end %>

  <%= submit_tag "Search" %>
  <%= link_to "Reset", posts_path %>
<% end %>
```

Note that it's responsible for setting the `value` based on the `params`.
Additionally, the options for `sort`, `author_id_eq`, and `status_in` are
rendered directly in the view.

Although this code works, we can simplify it **while** improving ergonomics by
extracting it into a model.

## Extract logic into a model

As mentioned before, the controller is responsible for validation and setting
default values. Those sound like the responsibilities of a model.

Let's start by extracting the logic, and mapping the parameters to attributes.

```ruby
# app/models/post/query.rb

class Post::Query
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :author_id_eq, :big_integer
  attribute :column, :string
  attribute :direction, :string
  attribute :sort, :string, default: "created_at desc"
  attribute :status_in, default: []
  attribute :title_or_body_contains, :string

  validates :column, inclusion: { in: %w[created_at title] }
  validates :direction, inclusion: { in: %w[asc desc] }

  def initialize(...)
    super
    self.sort = sort
  end

  def sort=(value)
    super
    column, direction = sort.split(" ")
    assign_attributes(column:, direction:)
  end

  def results
    if valid?
      sort_posts.then { filter_posts(_1) }
    else
      []
    end
  end

  private
    def sort_posts(scope = Post.all)
      scope.order("#{column} #{direction}")
    end

    def filter_posts(scope)
      filter_by_title_or_body(scope)
        .then { filter_by_status(_1) }
        .then { filter_by_author(_1) }
    end

    def filter_by_title_or_body(scope)
      if (title_or_body = title_or_body_contains.presence)
        scope.where("title LIKE ? or body LIKE ?", "%#{title_or_body}%", "%#{title_or_body}%")
      else
        scope
      end
    end

    def filter_by_status(scope)
      if (status = status_in.compact_blank.presence)
        scope.where(status:)
      else
        scope
      end
    end

    def filter_by_author(scope)
      if (author_id = author_id_eq.presence)
        scope.where(author_id:)
      else
        scope
      end
    end
end
```

Now we can effectively validate our attributes through the
[ActiveModel::Validations][] API instead of doing this in the controller.

We're also able to set default values thanks to the [ActiveModel::Attributes][]
API. Note that we assign the `column` and `direction` attributes from the `sort`
value on initialization, **or** when setting the `sort` value directly.

**Before**

```ruby
def sort_posts(scope)
  if (order = params.dig(:query, :sort))
    column, direction = order.split(" ")

    if column.presence_in(%w[title created_at]) && direction.presence_in(%w[asc desc])
      scope.order("#{column} #{direction}")
    else
     []
    end
  else
    scope.order(created_at: :desc)
  end
end
```

**After**

```ruby
def results
  if valid?
    sort_posts.then { filter_posts(_1) }
  else
    []
  end
end
```

With our logic extracted, we're now able to refactor our controller.

```diff
--- a/app/controllers/posts_controller.rb
+++ b/app/controllers/posts_controller.rb
@@ -3,7 +3,8 @@ class PostsController < ApplicationController

   # GET /posts or /posts.json
   def index
-    @posts = sort_posts(Post.all).then { filter_posts(_1) }
+    @query = Post::Query.new(params.fetch(:query, {}).permit(:author_id_eq, :sort, :title_or_body_contains, status_in: []))
+    @posts = @query.results
   end

   # GET /posts/1 or /posts/1.json
@@ -67,48 +68,4 @@ class PostsController < ApplicationController
     def post_params
       params.require(:post).permit(:title, :body, :status, :author_id)
     end
-
-    def sort_posts(scope)
-      if (order = params.dig(:query, :sort))
-        column, direction = order.split(" ")
-
-        if column.presence_in(%w[title created_at]) && direction.presence_in(%w[asc desc])
-          scope.order("#{column} #{direction}")
-        else
-          []
-        end
-      else
-        scope.order(created_at: :desc)
-      end
-    end
-
-    def filter_posts(scope)
-      filter_by_title_or_body(scope)
-        .then { filter_by_status(_1) }
-        .then { filter_by_author(_1) }
-    end
-
-    def filter_by_title_or_body(scope)
-      if (title_or_body = params.dig(:query, :title_or_body_contains).presence)
-        scope.where("title LIKE ? or body LIKE ?", "%#{title_or_body}%", "%#{title_or_body}%")
-      else
-        scope
-      end
-    end
-
-    def filter_by_status(scope)
-      if (status = params.dig(:query, :status_in)&.compact_blank&.presence)
-        scope.where(status:)
-      else
-        scope
-      end
-    end
-
-    def filter_by_author(scope)
-      if (author_id = params.dig(:query, :author_id_eq).presence)
-        scope.where(author_id:)
-      else
-        scope
-      end
-    end
 end
```

[ActiveModel::Validations]: https://guides.rubyonrails.org/active_model_basics.html#validations
[ActiveModel::Attributes]: https://guides.rubyonrails.org/active_model_basics.html#attributes

## Update the form

Since [form_with][] [pairs well with model objects][pairing], we can simplify
our existing form by passing in our new model to the `model` option.

This will alleviate the need to manually set the `value` based on the `params`.
Whatever values are set to the `Post::Query` during initialization will
automatically be set to the corresponding field's `value`.

```diff
--- a/app/views/posts/index.html.erb
+++ b/app/views/posts/index.html.erb
@@ -4,33 +4,24 @@

 <h1>Posts</h1>

-<%= form_with scope: :query, url: posts_path, method: :get do |form| %>
+<%= form_with model: @query, scope: :query, url: posts_path, method: :get do |form| %>
   <div>
     <%= form.label :title_or_body_contains, "Title or body contains" %>
-    <%= form.search_field :title_or_body_contains, value: params.dig(:query, :title_or_body_contains) %>
+    <%= form.search_field :title_or_body_contains %>
   </div>

   <div>
     <%= form.label :sort, "Sort by" %>
-    <%= form.select :sort, options_for_select(
-      [
-        ["Title - A to Z", "title asc"],
-        ["Title - Z to A", "title desc"],
-        ["Created At - Newest to Oldest", "created_at desc"],
-        ["Created At - Oldest to Newest", "created_at asc"]
-      ], params.dig(:query, :sort) || "created_at desc"
-    ) %>
+    <%= form.select :sort, @query.options_for_sort %>
   </div>

   <div>
     <%= form.label :author_id_eq, "Authored by" %>
-    <%= form.select :author_id_eq, options_from_collection_for_select(Author.all, "id", "name", params.dig(:query, :author_id_eq).to_i), {prompt: "Any"}  %>
+    <%= form.select :author_id_eq, @query.options_for_authored_by, {prompt: "Any"}  %>
   </div>

   <%= field_set_tag "Status" do %>
-    <%= form.collection_check_boxes(:status_in, Post.statuses.keys, :to_s, :capitalize) do |builder| %>
-      <%= builder.label { builder.check_box(checked: params.dig(:query, :status_in)&.include?(builder.value)) + builder.text } %>
-    <% end %>
+    <%= form.collection_check_boxes(:status_in, @query.options_for_status, :to_s, :capitalize) %>
   <% end %>

   <%= submit_tag "Search" %>
```

You'll also note that we were able to simplify how the `sort`, `author_id_eq`
and `status_in` options are set by placing that logic in the model.

```diff
--- a/app/models/post/query.rb
+++ b/app/models/post/query.rb
@@ -12,6 +12,23 @@ class Post::Query
   validates :column, inclusion: { in: %w[created_at title] }
   validates :direction, inclusion: { in: %w[asc desc] }

+  def options_for_sort
+    [
+      [ "Title - A to Z", "title asc" ],
+      [ "Title - Z to A", "title desc" ],
+      [ "Created At - Newest to Oldest", "created_at desc" ],
+      [ "Created At - Oldest to Newest", "created_at asc" ]
+    ]
+  end
+
+  def options_for_authored_by
+    Author.all.collect { [ _1.name, _1.id ] }
+  end
+
+  def options_for_status
+    Post.statuses.keys
+  end
+
   def initialize(...)
     super
     self.sort = sort
```

[form_with]: https://api.rubyonrails.org/v7.2.1/classes/ActionView/Helpers/FormHelper.html#method-i-form_with
[pairing]: https://guides.rubyonrails.org/form_helpers.html#creating-forms-with-model-objects

## A final touch

With our refactor nearly complete, there's still an opportunity to make a minor
improvement by having the `url` generated for us.

To achieve this, we'll need to reach for [resolve][]. What this does is map
`Post::Query` to `posts_url`, so that `form_with` knows how to build the `url`
automatically. This happens by default with Active Record objects.

```diff
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -12,4 +12,8 @@ Rails.application.routes.draw do

   # Defines the root path route ("/")
   root "posts#index"
+
+  resolve "Post::Query" do |model|
+    route_for :posts
+  end
 end
```

With the change to our routes, we can remove the `url` from our form, and rely
on [record identification][].

```diff
--- a/app/views/posts/index.html.erb
+++ b/app/views/posts/index.html.erb
@@ -4,7 +4,7 @@

 <h1>Posts</h1>

-<%= form_with model: @query, scope: :query, url: posts_path, method: :get do |form| %>
+<%= form_with model: @query, scope: :query, method: :get do |form| %>
   <div>
     <%= form.label :title_or_body_contains, "Title or body contains" %>
     <%= form.search_field :title_or_body_contains %>
```

[resolve]: https://guides.rubyonrails.org/routing.html#using-resolve
[record identification]: https://guides.rubyonrails.org/form_helpers.html#relying-on-record-identification

## Wrapping up

What we've done here is created a [form object][], but for a `GET` request.

While this concept isn't new and extends beyond search forms, the key takeaway
is how effectively `form_with` integrates with model objects. By using a model
object, we were able to drastically simplify our controller and form, and create
something that better adheres to Rails' conventions.

[form object]: https://thoughtbot.com/ruby-science/introduce-form-object.html
