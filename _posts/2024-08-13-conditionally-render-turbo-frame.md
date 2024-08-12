---
title: Conditionally render a Turbo Frame shared between multiple views
excerpt: We explore several solutions to a common Hotwire problem.
categories: ["Ruby on Rails"]
canonical_url: https://thoughtbot.com/blog/conditionally-render-turbo-frame
---

The [Turbo Frames API][turbo-frame-api] requires that a request made from within
a `turbo-frame` must receive a response containing a corresponding
`turbo-frame` of the same `id`.

Because Rails encourages the reuse of partials and views, this can lead to
situations where you need to [conditionally render a Turbo Frame][gh-1]. One
such example is inline editing, which we'll explore in this tutorial.

## Our Base

Our starting point does not yet warrant the need to conditionally render any of
the Turbo Frames because all three instances use the same HTML. Most notably
between the `show` and `index` views. This is because both of those views render
the `_post` partial.

![Editing a post inline, from the index view](https://images.thoughtbot.com/cjiqbjnz7fk4iaia3hw29rrsz28w_1.a.gif)

```erb
# app/views/posts/index.html.erb

<% @posts.each do |post| %>
  <%= turbo_frame_tag dom_id(post) do %>
    <%= render post %>
    <%= link_to "Edit", edit_post_path(post) %>
  <% end %>
<% end %>
```

```erb
# app/views/posts/_post.html.erb

<div>
  <p>
    <strong>Title:</strong>
    <%= post.title %>
  </p>

  <p>
    <strong>Body:</strong>
    <%= post.body %>
  </p>

</div>
```

When we click the "Edit" link from the `index` view, we load the corresponding
`turbo-frame` from the `edit` view. When the form is submitted, the `#update`
action redirects to the `show` view, which also contains a corresponding
`turbo-frame`.

```erb
# app/views/edit.html.erb

<%= turbo_frame_tag dom_id(@post) do %>
  <%= render "form", post: @post %>
  <%= link_to "Cancel", :back %>
<% end %>
```

```ruby
def update
  if @post.update(post_params)
    redirect_to post_url(@post), notice: "Post was successfully updated."
  else
    render :edit, status: :unprocessable_entity
  end
end
```

```erb
# app/views/posts/show.html.erb

<%= turbo_frame_tag dom_id(@post) do %>
  <%= render @post %>
  <%= link_to "Edit", edit_post_path(@post) %>
<% end %>
```

The key here is that the `index` and `show` views are both using the same
`_post` partial. This makes for a seamless experience. The only "gotcha" is that
this also means we've inadvertently enabled inline editing on the `show` page
too.

![Editing a post inline, from the edit view](https://images.thoughtbot.com/kusduh44pkuk3kicvjzqznbmhvbq_1.b.gif)

However, this is a contrived example and does not reflect a real-world design.
It's common to render content differently when viewed in different contexts.

Let's explore that next.

## The Problem

Let's update our `_post` partial and `show` view so that we see a teaser of the
post on the `index` page, and the full post on the `show` page.

```diff
--- a/app/views/posts/_post.html.erb
+++ b/app/views/posts/_post.html.erb
@@ -1,12 +1,12 @@
-<div>
-  <p>
-    <strong>Title:</strong>
-    <%= post.title %>
-  </p>
+<article>
+  <h2><%= post.title %></h2>

   <p>
-    <strong>Body:</strong>
-    <%= post.body %>
+    <%= post.body.truncate(20) %>
   </p>

-</div>
+  <td>
+    <%= link_to "Edit", edit_post_path(post) %>
+    <%= link_to "Show this post", post, data: { turbo_frame: "_top" } %>
+  </td>
+</article>
```

```diff
--- a/app/views/posts/index.html.erb
+++ b/app/views/posts/index.html.erb
@@ -8,11 +8,7 @@
   <% @posts.each do |post| %>
     <%= turbo_frame_tag dom_id(post) do %>
       <%= render post %>
-      <%= link_to "Edit", edit_post_path(post) %>
     <% end %>
-    <p>
-      <%= link_to "Show this post", post %>
-    </p>
   <% end %>
 </div>

```

```diff
--- a/app/views/posts/show.html.erb
+++ b/app/views/posts/show.html.erb
@@ -1,7 +1,10 @@
 <p style="color: green"><%= notice %></p>

 <%= turbo_frame_tag dom_id(@post) do %>
-  <%= render @post %>
+  <h1><%= @post.title %></h1>
+  <p>
+    <%= @post.body %>
+  </p>
   <%= link_to "Edit", edit_post_path(@post) %>
 <% end %>

```

Now that we're no longer sharing the same markup between the `index` view and
the `show` view, we end up rendering the markup for the `show` view when we edit
a post from the `index` view. Instead of rendering a teaser, we render the
whole post.

![Editing a post inline from the index view results in the full post being rendered after submitting the form](https://images.thoughtbot.com/r5i025rerml6xxcf9k42lum9nq12_2.a.gif)

However, this is not an issue when editing from the `edit` page, since we expect
to see the whole post after making an edit.

![Editing a post inline from the edit view does not result in a disjointed UI](https://images.thoughtbot.com/fsytp67sptp65uzye74n9l1r9va6_2.b.gif)

## A Simple Solution

Here's where we need introduce the concept of conditionally rendering a Turbo
Frame.

What we want to do is render the simple `_post` partial when a request is made
from the `index` view. Otherwise, if the request is made from the `edit` view,
we want to render the `show` view.

Fortunately, this can be easily solved with [`redirect_back_or_to`][rbot].

> Redirects the browser to the page that issued the request (the referrer) if
> possible, otherwise redirects to the provided default fallback location.

```diff
--- a/app/controllers/posts_controller.rb
+++ b/app/controllers/posts_controller.rb
@@ -33,7 +33,7 @@ class PostsController < ApplicationController
   # PATCH/PUT /posts/1 or /posts/1.json
   def update
     if @post.update(post_params)
-      redirect_to post_url(@post), notice: "Post was successfully updated."
+      redirect_back_or_to post_url(@post), notice: "Post was successfully updated."
     else
       render :edit, status: :unprocessable_entity
     end
```

In this case, when we edit a post from the `index` view, it will respond with
`index` which **already** has a `turbo-frame` rendering the `_post` partial. The
same concept applies for when editing a post from the `edit` view.

![Editing the post inline from the index view results in the teaser being rendered after submission](https://images.thoughtbot.com/djv5g70hedywno5ha8dzygb1phps_3.a.gif)

## A More Complex Example

Our current implementation only works because there's a `turbo-frame` on the
`index`, `show` and `edit` views. What if we didn't have that luxury? For
example, what if we didn't want to inline edit on the `show` page?

We can't use `redirect_back_or_to` because we want to redirect to the `show`
view when making an edit on the `edit` view, but still maintain inline editing
on the `index` view.

Fortunately, we can leverage [variants][] in concert with [parameters][] to
conditionally render our Turbo Frames based on specific context.

First, we can update our `_post` partial by having it link to the `edit` view,
but with a query string of `?variant=inline`.

```diff
--- a/app/views/posts/_post.html.erb
+++ b/app/views/posts/_post.html.erb
@@ -6,7 +6,7 @@
   </p>

   <td>
-    <%= link_to "Edit", edit_post_path(post) %>
+    <%= link_to "Edit", edit_post_path(post, variant: :inline) %>
     <%= link_to "Show this post", post, data: { turbo_frame: "_top" } %>
   </td>
 </article>
```

This means that when the request is made, we'll have the additional context
about how we want to render this response.

<aside class="info">
 Note that we can call our parameter anything we want. It does not need to be
<code>variant</code>.
</aside>

Now that we've encoded the context into the URL, we need to do something with
it. We can start by first creating a new [variant][variants] for the `edit` view that
will include the `turbo-frame`.

```erb
# app/views/posts/edit.html+inline.erb

<% content_for :title, "Editing post" %>

<h1>Editing post</h1>

<%= turbo_frame_tag dom_id(@post) do %>
  <%= render "form", post: @post %>
  <%= link_to "Cancel", :back %>
<% end %>
```

Since we're loading the form on this page, we can conditionally set a [hidden
field][] to capture this value and pass it over to the `#update` action so it is
informed of the context as well.

```diff
--- a/app/views/posts/_form.html.erb
+++ b/app/views/posts/_form.html.erb
@@ -21,6 +21,10 @@
     <%= form.text_area :body %>
   </div>

+  <% if params[:variant] == "inline" %>
+    <%= hidden_field_tag :variant, "inline", readonly: true %>
+  <% end %>
+
   <div>
     <%= form.submit %>
   </div>
```

Now that we have a variant responsible for including the `turbo-frame` in a
variant, we can remove it from the base `edit` view.

```diff
--- a/app/views/posts/edit.html.erb
+++ b/app/views/posts/edit.html.erb
@@ -2,11 +2,7 @@

 <h1>Editing post</h1>

-
-<%= turbo_frame_tag dom_id(@post) do %>
-  <%= render "form", post: @post %>
-  <%= link_to "Cancel", :back %>
-<% end %>
+<%= render "form", post: @post %>

 <br>

```

Now we just need to apply the same changes to the `show` views so that the
`update` action can conditionally render the appropriate [variant][variants] based on
the query parameter.

Similar to the above, we can create a [variant][variants] for the `show` view that will
contain a `turbo-frame`.

```erb
# app/views/posts/show.html+inline.erb

<%= turbo_frame_tag dom_id(@post) do %>
  <%= render @post %>
<% end %>
```

This means we can remove it from the base `show` view.

```diff
--- a/app/views/posts/show.html.erb
+++ b/app/views/posts/show.html.erb
@@ -1,12 +1,10 @@
 <p style="color: green"><%= notice %></p>

-<%= turbo_frame_tag dom_id(@post) do %>
-  <h1><%= @post.title %></h1>
-  <p>
-    <%= @post.body %>
-  </p>
-  <%= link_to "Edit", edit_post_path(@post) %>
-<% end %>
+<h1><%= @post.title %></h1>
+<p>
+  <%= @post.body %>
+</p>
+<%= link_to "Edit", edit_post_path(@post) %>

 <div>
   <%= link_to "Back to posts", posts_path %>
```

Now that we've modified the views, we need to update our controller to
conditionally chose the correct [variant][variants] based on the parameters.

```diff
--- a/app/controllers/posts_controller.rb
+++ b/app/controllers/posts_controller.rb
@@ -1,5 +1,6 @@
 class PostsController < ApplicationController
   before_action :set_post, only: %i[ show edit update destroy ]
+  before_action :set_variant, only: %i[ show edit update ]

   # GET /posts or /posts.json
   def index
@@ -8,6 +9,7 @@ class PostsController < ApplicationController

   # GET /posts/1 or /posts/1.json
   def show
+    request.variant = @variant
   end

   # GET /posts/new
@@ -17,6 +19,7 @@ class PostsController < ApplicationController

   # GET /posts/1/edit
   def edit
+    request.variant = @variant
   end

   # POST /posts or /posts.json
@@ -33,7 +36,7 @@ class PostsController < ApplicationController
   # PATCH/PUT /posts/1 or /posts/1.json
   def update
     if @post.update(post_params)
-      redirect_back_or_to post_url(@post), notice: "Post was successfully updated."
+      redirect_to post_url(@post, variant: @variant), notice: "Post was successfully updated."
     else
       render :edit, status: :unprocessable_entity
     end
@@ -56,4 +59,8 @@ class PostsController < ApplicationController
     def post_params
       params.require(:post).permit(:title, :body)
     end
+
+    def set_variant
+      @variant ||= :inline if params[:variant] == "inline"
+    end
 end
```

With this change in place, making edits on the `index` view returns the teaser
content.

![A teaser is still rendered when making edits from the index view](https://images.thoughtbot.com/djv5g70hedywno5ha8dzygb1phps_3.a.gif)

This change also means making edits from the `edit` page no longer happen
inline, as made evident by the presence of the flash message.

![We redirect to the show page after making an edit on the edit view.](https://images.thoughtbot.com/h11939hdmhvwxlevbjnmft8c5zr1_4.b.gif)

## Wrapping Up

Turbo Frames require a new mental model when it comes to managing the
state of a page. That, plus that fact that it's a relatively new technology
means that we're still exploring solutions to common problems as a community.

In this case, Turbo does not offer an off-the-shelf solution to conditionally
rendering Frames, but Rails does. I hope that moving forward, this post will
serve as guide when others are faced with the same problem.

[turbo-frame-api]: https://turbo.hotwired.dev/handbook/frames
[gh-1]: https://github.com/hotwired/turbo/issues/378
[rbot]: https://edgeapi.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_back_or_to
[variants]: https://edgeguides.rubyonrails.org/layouts_and_rendering.html#the-variants-option
[parameters]: https://edgeguides.rubyonrails.org/action_controller_overview.html#parameters
[hidden field]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/hidden
