---
title: Rails Ajax Examples (Without jQuery)
excerpt:
  Rails ships with turbolinks which creates a reactive, fast application. However, there are times when
  turbolinks is not enough, and you’ll want to roll your own AJAX solutions.
categories: ["Ruby on Rails"]
tags: ["AJAX"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/rails-ajax-examples",
    },
    {
      title: "Rails AJAX Documentation",
      url: "https://guides.rubyonrails.org/working_with_javascript_in_rails.html#a-simple-example",
    },
  ]
date: 2019-10-26
---

## Introduction

Rails ships with [turbolinks](https://github.com/turbolinks/turbolinks) which:

> automatically fetches the page, swaps in its `<body>`, and merges its `<head>`, all without incurring the cost of a full page load.

This creates a reactive, fast application. However, there are times when `turbolinks` is not enough, and you'll want to roll your own AJAX solutions.

{% youtube "https://www.youtube.com/embed/WbS65DsRLqk" %}

## Blueprint

Below is a generic blueprint to follow when implementing AJAX on the `create` action of a model in a Rails application.

### 1: Controller

Create a `respond_to` block and make sure to pass `format.js` in the block. This will automatically render a corresponding `create.js.erb` file. This file needs to be manually created in the corresponding `views` directory.

```ruby
def create
  @your_model = YourModel.create(your_model_params)
  respond_to do |format|
    if @your_model.save
      # This will run the code in `app/views/your_model/create.js.erb`.
      format.js
    else
      # This will run the code in `app/views/your_model/create.js.erb`.
      format.js
    end
  end
end
```

### 2: Form

Make sure your form does not use `local: true`. Otherwise, the form will not submit remotely.

```erb
<%= form_with model:@your_model do |f| %>
  ...
<% end %>
```

### 3: Create View

Handle errors and successful model creations with Javascript in your corresponding `app/views/your_model/create.js.erb` file. Note that any `ruby` code will get evaluated first. This means that you still have access helpful Rails layout and rendering methods, such as [Partials](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials).

```erb
# app/views/your_model/create.js.erb

<% if @your_model.errors.any? %>
  # Handle errors
<% else %>
  # Handle save
<% end %>
```

## Example 1: Dynamically Add a New Comment to a List of Comments with Ajax

In this scenario you want to post a new `comment` to a list of existing `comments` asynchronously.

![Add a comment via AJAX](/assets/images/posts/rails-ajax-examples/adding_a_comment_via_ajax.gif)

### Create View

```erb
<% if @comment.errors.any? %>
    <%# This removes any error messages that were previously generated. %>
    document.querySelector('#error_explanation') ? document.querySelector('#error_explanation').remove() : null ;
    <%# This selects the `<form>` in and dynamically injects the `app/views/shared/_validation-messages.html.erb` partial. %>
    document.querySelector('#comments-form').insertAdjacentHTML('afterbegin', '<%= escape_javascript(render "shared/validation-messages", object: @comment) %>');
<% else %>
    <%# This removes any error messages that were previously generated. %>
    document.querySelector('#error_explanation') ? document.querySelector('#error_explanation').remove() : null ;
    <%# This selects `<div id="comments">` and dynamically injects the `app/views/comments/_comment.html.erb` partial. %>
    document.querySelector('#comments').insertAdjacentHTML('afterbegin', '<%= escape_javascript(render @comment) %>') ;
    <%# This selects the `<form>` and resets the text area. %>
    document.querySelector('#comments-form').reset();
<% end %>
```

## Example 2: Dynamically Add a New Author to a Select List of Existing Authors

In this scenario you want to create a new `author` while adding or editing an existing `post` that relies on a relationship with an `author`.

![Add an author via AJAX](/assets/images/posts/rails-ajax-examples/adding_an_author_via_ajax.gif)

### Create View

```erb
<% if @author.errors.any? %>
    <%# This removes any error messages that were previously generated. %>
    document.querySelector('#error_explanation') ? document.querySelector('#error_explanation').remove() : null ;
    <%# This selects the new author `<form>` and dynamically injects the `app/views/shared/_validation-messages.html.erb` partial. %>
    document.querySelector('#author_form').insertAdjacentHTML('afterbegin', '<%= escape_javascript(render "shared/validation-messages", object: @author) %>');
<% else %>
    <%# This removes any error messages that were previously generated. %>
    document.querySelector('#error_explanation') ? document.querySelector('#error_explanation').remove() : null ;
    <%# This searches for the currently selected author and unselects them. %>
    document.querySelector("select#post_author_id option[selected='selected']") ? document.querySelector("select#post_author_id option[selected='selected']").removeAttribute('selected') : null ;
    <%# This dynamically adds the newly created author into the author select list, and sets them to be selected. %>
    document.querySelector('select#post_author_id').insertAdjacentHTML('afterbegin', '<option value="<%= @author.id %>" selected="selected" ><%= @author.formatted_name %></option>') ;
    <%# This selects the new author `<form>` and resets the text fields. %>
    document.querySelector('#author_form').reset();
<% end %>
```
