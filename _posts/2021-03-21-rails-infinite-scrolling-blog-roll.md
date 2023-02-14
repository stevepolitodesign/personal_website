---
title: "Create an infinite scrolling blog roll in Rails with Hotwire"
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/rails-infinite-scroll-posts",
    },
    { title: "Hotwire", url: "https://hotwire.dev/" },
    {
      title: "Turbo Frames HTML Attributes",
      url: "https://turbo.hotwire.dev/reference/frames#html-attributes",
    },
  ]
date: 2021-03-21
---

In this tutorial, I'll show you how to add an infinitely scrolling blog roll using Rails and Hotwire. Note that this is different than [Chris Oliver's awesome infinite scroll tutorial](https://gorails.com/episodes/infinite-scroll-stimulus-js), in that we're loading a new post once a user scrolls to the bottom of a current post. Below is a demo.

![demo](/assets/images/posts/rails-infinite-scrolling-blog-roll/demo.gif)

## Step 1: Application Set-Up

1. `rails new rails-infinite-scroll-posts -d-postgresql --webpacker=stimulus`
2. `rails db:setup`
3. `bundle add turbo-rails`
4. `rails turbo:install`

## Step 2: Create Post Scaffold

1. `rails g scaffold post title body:text`
2. `rails db:migrate`

## Step 3: Add Seed Data

1. `bundle add faker -g=development`
2. Update `db/seeds.rb `

   ```ruby
   10.times do |i|
     Post.create(
       title: "Post #{i + 1}",
       body: Faker::Lorem.paragraph(sentence_count: 500),
     )
   end
   ```

3. `rails db:seed`

## Step 4. Create the ability to navigate between Posts

1. `touch app/models/concerns/navigable.rb`

   ```ruby
   module Navigable
     extend ActiveSupport::Concern
   
     def next
       self.class.where("id > ?", self.id).order(id: :asc).first
     end
   
     def previous
       self.class.where("id < ?", self.id).order(id: :desc).first
     end
   end
   ```

2. Include Module in Post Model

   ```ruby
   class Post < ApplicationRecord
     include Navigable
   end
   ```

   > Note: We could just add the `next` and `previous` methods directly in the `Post` model, but using a Module means we can use these methods in future models.

3. Update PostsController

   ```ruby
   class PostsController < ApplicationController
     def show
       @next_post = @post.next
     end
   end
   ```

## Step 5: Use Turbo Frames to lazy-load the next Post

1. Add frames to `app/views/posts/show.html.erb`

   ```erb
   <p id="notice"><%= notice %></p>
   <%# ℹ️ Add a turbo_frame_tag %>
   <%= turbo_frame_tag dom_id(@post) do %>
     <p>
       <strong>Title:</strong>
       <%= @post.title %>
     </p>
     <p>
       <strong>Body:</strong>
       <%= @post.body %>
     </p>
     <%# ℹ️ Add data_turbo_frame attribute %>
     <%= link_to 'Edit', edit_post_path(@post), data: { turbo_frame: "_top" } %> |
     <%= link_to 'Back', posts_path, data: { turbo_frame: "_top" } %>
     <%= turbo_frame_tag dom_id(@next_post), loading: :lazy, src: post_path(@next_post) if @next_post.present? %>
   <% end %>
   ```

**What's going on?**

- We wrap the content in a `turbo_frame_tag` with an `ID` of `dom_id(@post)`. For example, the `dom_id(@post)` call will evaluate to `id="post_1"`if the Post's ID is 1. This keeps the ID's unique.
- We add another `turbo_frame_tag` within the outer `turbo_frame_tag` to [lazy-load](https://turbo.hotwire.dev/reference/frames#lazy-loaded-frame) the next post. We can look for the next post thanks to our `Navigable` module that we created earlier.
  - The `loading` attribute ensures that the frame will only load once it appears in the viewport.
- We add `data: { turbo_frame: "_top" }` to [override navigation targets](https://turbo.hotwire.dev/reference/frames#frame-with-overwritten-navigation-targets) and force those pages to replace the whole frame. Otherwise, we would need to add Turbo Frames to the `edit` and `index` views.
  - This is only because those links are nested in the outermost `turbo_frame_tag`.

## Step 6: Use Stimulus to update the path as new posts are loaded

1. `touch app/javascript/controllers/infinite_scroll_controller.js`

   ```javascript
   import { Controller } from "stimulus";

   export default class extends Controller {
     static targets = ["entry"];
     static values = {
       path: String,
     };

     connect() {
       this.createObserver();
     }

     createObserver() {
       let observer;

       let options = {
         // https://github.com/w3c/IntersectionObserver/issues/124#issuecomment-476026505
         threshold: [0, 1.0],
       };

       observer = new IntersectionObserver(
         (entries) => this.handleIntersect(entries),
         options
       );
       observer.observe(this.entryTarget);
     }

     handleIntersect(entries) {
       entries.forEach((entry) => {
         if (entry.isIntersecting) {
           // https://github.com/turbolinks/turbolinks/issues/219#issuecomment-376973429
           history.replaceState(history.state, "", this.pathValue);
         }
       });
     }
   }
   ```

2. Update that markup in `app/views/posts/show.html.erb`

   ```erb
   <p id="notice"><%= notice %></p>
   <%= turbo_frame_tag dom_id(@post) do %>
     <%# ℹ️ Wrap the content in a controller so it's scoped %>
     <div data-controller="infinite-scroll" data-infinite-scroll-path-value="<%= post_path(@post) %>" data-infinite-scroll-target="entry">
       <p>
         <strong>Title:</strong>
         <%= @post.title %>
       </p>
       <p>
         <strong>Body:</strong>
         <%= @post.body %>
       </p>
       <%= link_to 'Edit', edit_post_path(@post), data: { turbo_frame: "_top" } %> |
       <%= link_to 'Back', posts_path, data: { turbo_frame: "_top" }  %>
     </div>
     <%= turbo_frame_tag dom_id(@next_post), loading: :lazy, src: post_path(@next_post) if @next_post.present? %>
   <% end %>
   ```

**What's going on?**

- We use the [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API) to determine when the post has entered the viewport.
  - We set the `threshold` to `[0, 1.0]` to [account for elements that are taller than the viewport](https://github.com/turbolinks/turbolinks/issues/219#issuecomment-376973429). This ensures that `entry.isIntersecting` will return `true`.
- When `entry.isIntersecting` returns `true`, we use [History.replaceState()](https://developer.mozilla.org/en-US/docs/Web/API/History/replaceState) to update the URL with the path for the post that entered the viewport.
  - The value for the path is stored in the `data-infinite-scroll-path-value` attribute.
  - We add `history.state` as the first argument to `history.replaceState` to account for an issue with [Turbolinks](https://github.com/turbolinks/turbolinks/issues/219#issuecomment-376973429).

## Step 7: Add a loading state and styles (optional)

1. Add Bootstrap via CDN to `app/views/layouts/application.html.erb`

   ```erb
   <!DOCTYPE html>
   <html>
     <head>
       <title>RailsInfiniteScrollPosts</title>
       <meta name="viewport" content="width=device-width,initial-scale=1">
       <%= csrf_meta_tags %>
       <%= csp_meta_tag %>

       <%# ℹ️ Load Bootstrap %>
       <%= stylesheet_link_tag 'https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css', integrity: 'sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl', crossorigin: 'anonymous' %>
       <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
       <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

     </head>

     <body>
       <%# ℹ️ Add a container %>
       <div class="container">
         <%= yield %>
       </div>
     </body>
   </html>
   ```

2. Update markup and add a loader to `app/views/posts/show.html.erb`

   ```erb
   <p id="notice"><%= notice %></p>
   <%= turbo_frame_tag dom_id(@post) do %>
     <article data-controller="infinite-scroll" data-infinite-scroll-path-value="<%= post_path(@post) %>" data-infinite-scroll-target="entry">
       <h2><%= @post.title %></h2>
       <p><%= @post.body %></p>
       <%= link_to 'Edit', edit_post_path(@post), data: { turbo_frame: "_top" } %> |
       <%= link_to 'Back', posts_path, data: { turbo_frame: "_top" }  %>
     </article>
     <%= turbo_frame_tag dom_id(@next_post), loading: :lazy, src: post_path(@next_post) do %>
       <div class="d-flex justify-content-center">
         <div class="spinner-border" role="status">
           <span class="visually-hidden">Loading...</span>
         </div>
       </div>
     <% end if @next_post.present? %>
   <% end %>
   ```
