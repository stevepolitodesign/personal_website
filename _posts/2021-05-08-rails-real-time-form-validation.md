---
title: "Real-time Form Validation in Ruby on Rails"
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/rails-real-time-form-validation",
    },
  ]
date: 2021-05-08
---

Learn how to validate a form in real-time while conditionally preventing it from being submitted.

![demo](/assets/images/posts/rails-real-time-form-validation/demo.gif)

## Step 1: Initial Set Up

1. `rails new rails-real-time-form-validation --webpack=stimulus`
2. `rails g scaffold Post title body:text`
3. `rails db:migrate`

## Step 2: Add Validations to Post Model

```ruby
# app/models/post.rb

class Post < ApplicationRecord
  validates :body, length: { minimum: 10 }
  validates :title, presence: true
end
```

## Step 3: Create Form Validation Endpoint

1. `rails g controller form_validations/posts`
2. Update controller to inherit from `PostsController`

   ```ruby
   # app/controllers/form_validations/posts_controller.rb
   
   class FormValidations::PostsController < PostsController
     def update
       @post.assign_attributes(post_params)
       @post.valid?
       respond_to do |format|
         format.text do
           render partial: "posts/form", locals: { post: @post }, formats: [:html]
         end
       end
     end
   
     def create
       @post = Post.new(post_params)
       @post.validate
       respond_to do |format|
         format.text do
           render partial: "posts/form", locals: { post: @post }, formats: [:html]
         end
       end
     end
   end
   ```

   > **What's Going On?**
   >
   > When we hit this endpoint we return the form partial as response from the server. The form partial already handles the logic needed to render errors.
   >
   > - We have access to `post_params` becuase we inherit from `PostsController`
   > - We call [assign_attributes](https://api.rubyonrails.org/classes/ActiveModel/AttributeAssignment.html#method-i-assign_attributes) in the `update` action because we don't actually want to update the record in the database. We just want to update the record in memory so that we can have it validated.
   > - We call `@post.valid?` and `@post.validate` in the `update` and `create` actions respectively to ensure any validation errors get sent to the partial.
   > - We respond `text` and not `json` because we would need to format the response with a `key` to hold the markup. This way is easier. We pass `formats: [:html]` to ensure the correct partial is rendered. Othwerwise Rails would look for `_form.text.erb`.

3. Create a namespaced route for the endpoints.

   ```ruby
   # config/routes.rb
   
   Rails.application.routes.draw do
     resources :posts
     namespace :form_validations do
       resources :posts, only: %i[create update]
     end
   end
   ```

> **What's Going On?**
>
> We don't have to namespace this controller and route, but it keeps things organized. This will make it easier to create additional enpoints for other forms. There's probably an opportunity to use metaprogramming and concerns, but for now this works.

## Step 4: Create Stimulus Controller

1. `touch app/javascript/controllers/form_validation_controller.js`

   ```js
   // app/javascript/controllers/form_validation_controller.js
   import Rails from "@rails/ujs";
   import { Controller } from "stimulus";

   export default class extends Controller {
     static targets = ["form", "output"];
     static values = { url: String };

     handleChange(event) {
       Rails.ajax({
         url: this.urlValue,
         type: "POST",
         data: new FormData(this.formTarget),
         success: (data) => {
           this.outputTarget.innerHTML = data;
         },
       });
     }
   }
   ```

   > **What's Going On?**
   >
   > This Stimulus Controller simply hits the endpoint we created and updates the DOM with the response.
   >
   > - We import `Rails` in order to use `Rails.ajax`
   > - We set the `url` to the value we will pass to `data-form-validation-url-value` keepig thing flexible.
   > - We set the `type` to `POST` to ensure we're always make a `POST` request to the endpoint.
   > - We set the `data` to `new FormData(this.formTarget)` wich simply takes all the values from the form.
   >   - Note that this includes the hidden [method](https://guides.rubyonrails.org/form_helpers.html#how-do-forms-with-patch-put-or-delete-methods-work-questionmark) input which will account for `PATCH` requsts. This is why we need to have `create` and `update` actions on our controller.

2. Update markup.

   ```erb
   <%# app/views/posts/_form.html.erb %>
   <%= form_with(model: post, data: { form_validation_target: "form" }) do |form| %>
     <% if post.errors.any? %>
     <div id="error_explanation">
       <h2><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h2>
       <ul>
         <% post.errors.each do |error| %>
           <li><%= error.full_message %></li>
         <% end %>
       </ul>
     </div>

     <% end %>
     <div class="field">
       <%= form.label :title %>
       <%= form.text_field :title, data: { action: "form-validation#handleChange" } %>
     </div>

     <div class="field">
       <%= form.label :body %>
       <%= form.text_area :body, data: { action: "form-validation#handleChange" } %>
     </div>

     <div class="actions">
       <%= form.submit disabled: post.errors.any?  %>
     </div>
   <% end %>
   ```

   > **What's Going On?**
   >
   > - We add a [target](https://stimulus.hotwire.dev/reference/targets) to our form in order to easily send the form data to the endpoint through our controller.
   > - We add an [action](https://stimulus.hotwire.dev/reference/actions) to any input we want to listen to. When the change event is fired we hit our endpoint.
   > - We conditionally disable the form by adding `disabled: post.errors.any?` to the submit button.

   ```erb
   <%# app/views/posts/new.html.erb %>

   <h1>New Post</h1>

   <div data-controller="form-validation" data-form-validation-target="output" data-form-validation-url-value="<%= form_validations_posts_path %>">
     <%= render 'form', post: @post %>
   </div>

   <%= link_to 'Back', posts_path %>
   ```

   ```erb
   <%# app/views/posts/edit.html.erb %>

   <h1>Editing Post</h1>

   <div data-controller="form-validation" data-form-validation-target="output" data-form-validation-url-value="<%= form_validations_post_path(@post) %>">
     <%= render 'form', post: @post %>
   </div>

   <%= link_to 'Show', @post %> |
   <%= link_to 'Back', posts_path %>
   ```

If you open your browser and navigate to [http://localhost:3000/posts/new](http://localhost:3000/posts/new) you can inspect the response from the server and see our work in progress.

![server response](/assets/images/posts/rails-real-time-form-validation/server_response.png)

## Step 5: Debounce Requests

1. `yarn add lodash.debounce`

```js
// app/javascript/controllers/form_validation_controller.js
import Rails from "@rails/ujs";
import { Controller } from "stimulus";
const debounce = require("lodash.debounce");

export default class extends Controller {
  static targets = ["form", "output"];
  static values = { url: String };

  initialize() {
    this.handleChange = debounce(this.handleChange, 500).bind(this);
  }

  handleChange(event) {
    Rails.ajax({
      url: this.urlValue,
      type: "POST",
      data: new FormData(this.formTarget),
      success: (data) => {
        this.outputTarget.innerHTML = data;
      },
    });
  }
}
```

> **What's Going On?**
>
> Over server is hit everytime someone types into this form unless we debounce these requests. By debouncing these requests we reduce the load on the server, and also reduce some jank on the form.
>
> If you open your browser and navigate to [http://localhost:3000/posts/new](http://localhost:3000/posts/new) you can inspect the response from the server and see that only one request was made instead of one per keystroke.

![debounce](/assets/images/posts/rails-real-time-form-validation/debounce.gif)

## Step 6: Focus Input

You might have noticed that each time the form validates, the cursor is no longer focused on the input. Let's fix that.

![no focus](/assets/images/posts/rails-real-time-form-validation/no_focus.gif)

```js
import Rails from "@rails/ujs";
import { Controller } from "stimulus";
const debounce = require("lodash.debounce");

export default class extends Controller {
  static targets = ["form", "output"];
  static values = { url: String };

  initialize() {
    this.handleChange = debounce(this.handleChange, 500).bind(this);
  }

  handleChange(event) {
    let input = event.target;
    Rails.ajax({
      url: this.urlValue,
      type: "POST",
      data: new FormData(this.formTarget),
      success: (data) => {
        this.outputTarget.innerHTML = data;
        input = document.getElementById(input.id);
        this.moveCursorToEnd(input);
      },
    });
  }

  // https://css-tricks.com/snippets/javascript/move-cursor-to-end-of-input/
  moveCursorToEnd(element) {
    if (typeof element.selectionStart == "number") {
      element.focus();
      element.selectionStart = element.selectionEnd = element.value.length;
    } else if (typeof element.createTextRange != "undefined") {
      element.focus();
      var range = element.createTextRange();
      range.collapse(false);
      range.select();
    }
  }
}
```

> **What's Going On?**
>
> - We store the focused `input` as a variable by calling `let input = event.target`.
> - We do this because the form's makrup get's replaced after the request to the server is made. This allows is to still reference the `input` later by calling `input = document.getElementById(input.id);`. There's probably a better way to do this, but it works.
> - We can't just call [focus()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLOrForeignElement/focus) on the `input` because it will place the cursor at the beginning. Fortunately a quick internet search lead me to [this solution](https://css-tricks.com/snippets/javascript/move-cursor-to-end-of-input/).
> - Note that I added `element.focus();` after `typeof element.selectionStart == "number"`.

If you open your browser and navigate to [http://localhost:3000/posts/new](http://localhost:3000/posts/new) you'll see that the cursor is placed at the end.

![set focus](/assets/images/posts/rails-real-time-form-validation/set_focus.gif)
