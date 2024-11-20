---
title: Process slow network requests with Turbo and Active Model
excerpt: Learn how to build a dynamic loading screen without writing a line of JavaScript.
category: ["Ruby on Rails"]
tags: ["Tutorial"]
canonical_url: https://thoughtbot.com/blog/process-network-requests-with-turbo
---

I recently had the opportunity to improve the UX on a client project by
backgrounding a slow network request and broadcasting the response to the
browser asynchronously with Turbo.

At first, I was a little overwhelmed because I didn't know _exactly_ how to do
this. The response was mapped to a Ruby object, and was not Active Record
backed, so I wasn't sure how to leverage Turbo. However, I found it to be
surprisingly easy, and I wanted to share the highlights through a distilled
example.

Although we'll be focusing on network requests, I want to highlight that this
approach works for all types of slow operations.

Here's an outline of what we're trying to accomplish.

1. A request is made that triggers a slow operation that normally would result in a timeout.
2. Move that slow operation to a background job to be processed asynchronously.
3. Render a loading screen while the job is being processed.
4. Once the background job is finished processing, update the client accordingly.

Feel free to follow along below, or view the [final code][final] which lives
in our [Hotwire Example Template][het].

## Our base

We'll start with a simple [Active Model backed form][am-form] where the user
enters the ID for a record stored in an external system. Since the record is
stored in an external system, we issue a network request to retrieve it. Note
that the page can't respond until the request is processed, resulting in a poor
user experience.

![Filling out a form results in the page locking up, and taking a long time to render the response](https://images.thoughtbot.com/lqtrehn5uog3ndf3pukwaynpw83e_CleanShot%202024-11-08%20at%2016.39.37.gif)

The controller and corresponding model aren't particularly interesting.
The only thing worth mentioning is that we're calling `OrderSearch#process` in
our controller, which issues the network request in-line.

```ruby
# app/controllers/orders_controller.rb

class OrdersController < ApplicationController
  def index
    @order_search = OrderSearch.new(order_id: params[:order_id])
    @order_search.process
  end
end
```

```ruby
# app/models/order_search.rb

class OrderSearch
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :order_id, :big_integer
  attribute :result

  alias_method :processed?, :result

  def processing?
    order_id && result.nil?
  end

  def process
    return unless processing?

    # Simulate network request
    sleep 1

    # Simulate building result from response
    self.result = Order.new(id: order_id, product: "Some Widget", quantity: 1)
  end
end
```

It's worth highlighting that we're mapping the response from our
network request to a non-persisted [Active Model][am] object.

```ruby
# Simulate building result from response
self.result = Order.new(id: order_id, product: "Some Widget", quantity: 1)
```

The corresponding views are just as unremarkable.

```erb
<% # app/views/orders/index.html.erb %>

<%= form_with model: @order_search, scope: "", method: :get do |form| %>
  <%= form.label :order_id, "Order ID" %>
  <%= form.number_field :order_id, required: true %>

  <%= form.submit "Find order" %>
<% end %>

<%= render @order_search %>
```

```erb
<% # app/views/order_searches/_order_search.html.erb %>

<% if order_search.processing? %>
  <p>Searching...</p>
<% elsif order_search.processed? %>
  <%= render order_search.result %>
<% end %>
```

## Process request in the background

With our setup out of the way, we can improve the UX by backgrounding the
network request in a [job][aj] which will allow the controller to respond
immediately.

```diff
--- a/app/models/order_search.rb
+++ b/app/models/order_search.rb
@@ -14,10 +14,6 @@ class OrderSearch
   def process
     return unless processing?

-    # Simulate network request
-    sleep 1
-
-    # Simulate building result from response
-    self.result = Order.new(id: order_id, product: "Some Widget", quantity: 1)
+    GetOrderJob.perform_later(self)
   end
 end
```

Our job is not only responsible for processing the request, but also for
broadcasting the response back to the page.

In order to do this, we'll need to rely on some lower-level APIs provided by
Turbo Rails and Rails.

First, we'll use [`Turbo::StreamsChannel`][tsc] which is extended by
[`Turbo::Streams::Broadcasts`][tsb] and [`Turbo::Streams::StreamName`][tss] to
broadcast the response back to the page by passing the `order_search` as the
first argument.

We use [`dom_id`][dom_id] to generate an identifier from the `order_search`
instance. We're not required to use `dom_id`, but we are required to ensure
the view we're broadcasting to has an element with the same identifier.

Finally, we need to ensure we actually broadcast something to the page. We
_could_ build up the HTML by hand, but since we already have an existing
partial, we can just call [`render`][render] and pass in the partial path and
object to build the content.

```ruby
# app/jobs/get_order_job.rb

class GetOrderJob < ActiveJob::Base
  def perform(order_search)
    # Simulate network request
    sleep 1

    # Simulate building result from response
    order_search.result = Order.new(id: order_search.order_id, product: "Some Widget", quantity: 1)

    Turbo::StreamsChannel.broadcast_replace_to(
      order_search,
      target: ActionView::RecordIdentifier.dom_id(order_search),
      content: build_content(order_search)
    )
  end

  private

  def build_content(order_search)
    ApplicationController.render(
      partial: "order_searches/order_search",
      locals: { order_search: }
    )
  end
end
```

### Creating a custom serializer

Since Active Job does not support Active Model instances as a type of
[argument][aj-arg], we'll need to create a custom [serializer][] and make some
changes to our application's configuration.

```ruby
# app/serializers/order_search_serializer.rb

class OrderSearchSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize(order_search)
    super(
      "order_id" => order_search.order_id,
      "result" => order_search.result
    )
  end

  def deserialize(hash)
    OrderSearch.new(order_id: hash["order_id"], result: hash["result"])
  end

  private

  def klass
    OrderSearch
  end
end
```

```diff
--- a/config/application.rb
+++ b/config/application.rb
@@ -23,5 +23,6 @@ module HotwireExamples
     #
     # config.time_zone = "Central Time (US & Canada)"
     # config.eager_load_paths << Rails.root.join("extras")
+    config.autoload_once_paths << "#{root}/app/serializers"
   end
 end
```

```ruby
# config/initializers/custom_serializers.rb

Rails.application.config.active_job.custom_serializers << OrderSearchSerializer
```

Finally, we need to add a corresponding identifier to our view to map to the
`target` option from above. We also need to add a [`turbo_stream_from`][tsf]
element to the page so that it can receive the broadcast from our job.

```diff
--- a/app/views/order_searches/_order_search.html.erb
+++ b/app/views/order_searches/_order_search.html.erb
@@ -1,5 +1,8 @@
-<% if order_search.processing? %>
-  <p>Searching...</p>
-<% elsif order_search.processed? %>
-  <%= render order_search.result %>
-<% end %>
+<div id="<%= dom_id(order_search) %>">
+  <% if order_search.processing? %>
+    <%= turbo_stream_from order_search %>
+    <p>Searching...</p>
+  <% elsif order_search.processed? %>
+    <%= render order_search.result %>
+  <% end %>
+</div>
```

With these changes in place, we should have a much smoother user experience.

![Filling out a form results in a loading screen that is eventually replaced with content](https://images.thoughtbot.com/hkhcig70n3ybeikwsq5iz229dajk_CleanShot%202024-11-08%20at%2016.38.33.gif)

## Leverage Turbo::Broadcastable

If you were reading the last section and thought it was a smell to leverage all
those low level APIs, you're right.

What we did was essentially recreate the [`Turbo::Broadcastable`][tb] API. We
did this because we didn't have access to it, since it's only included in Active
Record, and we're using Active Model.

We can dramatically improve our implementation simply by including it in our
model, and calling [`broadcast_replace`][brp].

```diff
diff --git a/app/models/order_search.rb b/app/models/order_search.rb
index da22b7c..3621101 100644
--- a/app/models/order_search.rb
+++ b/app/models/order_search.rb
@@ -1,6 +1,7 @@
 class OrderSearch
   include ActiveModel::Model
   include ActiveModel::Attributes
+  include Turbo::Broadcastable

   attribute :order_id, :big_integer
   attribute :result
```

```diff
--- a/app/jobs/get_order_job.rb
+++ b/app/jobs/get_order_job.rb
@@ -6,19 +6,6 @@ class GetOrderJob < ActiveJob::Base
     # Simulate building result from response
     order_search.result = Order.new(id: order_search.order_id, product: "Some Widget", quantity: 1)

-    Turbo::StreamsChannel.broadcast_replace_to(
-      order_search,
-      target: ActionView::RecordIdentifier.dom_id(order_search),
-      content: build_content(order_search)
-    )
-  end
-
-  private
-
-  def build_content(order_search)
-    ApplicationController.render(
-      partial: "order_searches/order_search",
-      locals: { order_search: }
-    )
+    order_search.broadcast_replace
   end
 end
```

I want to highlight that this works so seamlessly because we closely adhered to
Rails conventions from the start. Most notably, regarding where we placed
our partials, and the inclusion of `ActiveModel::Model` in `OrderSearch`.

However, even if we hadn't, we could still have leveraged
[`broadcast_replace_to`][brt] to control the broadcast without all the ceremony
from before.

## Scope broadcast to the current user

Finally, I wanted to share some pragmatic advice in regards to scoping the
broadcast to the current user.

Since it's more than likely your application is using authentication, you'll
want to scope these broadcasts to the user that issued them.

Below is what that might look like.

```diff
--- a/app/models/order_search.rb
+++ b/app/models/order_search.rb
@@ -5,6 +5,7 @@ class OrderSearch

   attribute :order_id, :big_integer
   attribute :result
+  attribute :user

   alias_method :processed?, :result
```

```diff
--- a/app/controllers/orders_controller.rb
+++ b/app/controllers/orders_controller.rb
@@ -1,6 +1,6 @@
 class OrdersController < ApplicationController
   def index
-    @order_search = OrderSearch.new(params.permit!.slice(:order_id))
+    @order_search = OrderSearch.new(params.permit!.slice(:order_id).with_defaults(user: current_user))
     @order_search.process
   end
 end
```

The key is that we now pass the user **and** the object to `turbo_stream_from`,
and ensure we're broadcasting to that stream by using `broadcast_replace_to`
which also accepts the user **and** the object.

```diff
--- a/app/views/order_searches/_order_search.html.erb
+++ b/app/views/order_searches/_order_search.html.erb
@@ -1,6 +1,6 @@
 <div id="<%= dom_id(order_search) %>">
   <% if order_search.processing? %>
-    <%= turbo_stream_from order_search %>
+    <%= turbo_stream_from order_search.user, order_search %>
     <p>Searching...</p>
   <% elsif order_search.processed? %>
     <%= render order_search.result %>
```

```diff
--- a/app/jobs/get_order_job.rb
+++ b/app/jobs/get_order_job.rb
@@ -6,6 +6,6 @@ class GetOrderJob < ActiveJob::Base
     # Simulate building result from response
     order_search.result = Order.new(id: order_search.order_id, product: "Some Widget", quantity: 1)

-    order_search.broadcast_replace
+    order_search.broadcast_replace_to order_search.user, order_search
   end
 end
```

We just need to make sure to update our serializer too.

```diff
--- a/app/serializers/order_search_serializer.rb
+++ b/app/serializers/order_search_serializer.rb
@@ -2,12 +2,13 @@ class OrderSearchSerializer < ActiveJob::Serializers::ObjectSerializer
   def serialize(order_search)
     super(
       "order_id" => order_search.order_id,
-      "result" => order_search.result
+      "result" => order_search.result,
+      "user" => order_search.user
     )
   end

   def deserialize(hash)
-    OrderSearch.new(order_id: hash["order_id"], result: hash["result"])
+    OrderSearch.new(order_id: hash["order_id"], result: hash["result"], user: hash["user"])
   end

   private
```

## Wrapping up

I used to think of Turbo as something that was exclusive to Active Record.
However, as we just demonstrated, that's not the case.

Turbo can work just as seamlessly with Active Model-like objects, especially
when you're closely adhering to Rails conventions.

Finally, this approach doesn't need to be limited to network requests. We can
use the same pattern to handle any type of process that needs to be run in the
background, such as a large calculation or query.

[am-form]: https://thoughtbot.com/blog/rails-search-form-tutorial
[aj]: https://guides.rubyonrails.org/active_job_basics.html
[tsc]: https://rubydoc.info/github/hotwired/turbo-rails/Turbo/StreamsChannel
[tsb]: https://rubydoc.info/github/hotwired/turbo-rails/Turbo/Streams/Broadcasts
[tss]: https://rubydoc.info/github/hotwired/turbo-rails/Turbo/Streams/StreamName
[dom_id]: https://api.rubyonrails.org/classes/ActionView/RecordIdentifier.html#method-i-dom_id
[render]: https://api.rubyonrails.org/classes/ActionController/Renderer.html#method-i-render
[aj-arg]: https://guides.rubyonrails.org/active_job_basics.html#supported-types-for-arguments
[serializer]: https://guides.rubyonrails.org/active_job_basics.html#serializers
[tsf]: https://rubydoc.info/github/hotwired/turbo-rails/Turbo/StreamsHelper#turbo_stream_from-instance_method
[tb]: https://rubydoc.info/github/hotwired/turbo-rails/Turbo/Broadcastable
[br]: https://rubydoc.info/github/hotwired/turbo-rails/Turbo/Broadcastable
[brp]: https://rubydoc.info/github/hotwired/turbo-rails/Turbo%2FBroadcastable:broadcast_replace
[brt]: https://rubydoc.info/github/hotwired/turbo-rails/Turbo%2FBroadcastable:broadcast_replace_to
[am]: https://guides.rubyonrails.org/active_model_basics.html
[final]: https://github.com/thoughtbot/hotwire-example-template/compare/main...hotwire-example-process-network-request
[het]: https://github.com/thoughtbot/hotwire-example-template
