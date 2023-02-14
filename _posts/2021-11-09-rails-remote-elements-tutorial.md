---
title: "Rails Remote Elements Tutorial"
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/rails-remote-elements-tutorial/",
    },
  ]
date: 2021-11-09
og_image: "https://mugshotbot.com/m/s6WZrmo1"
---

Do you need to create real-time features in your Rails app, but either can't use Turbo or don't want to use a front end framework like React? Fortunately older versions of Rails actually provide this functionality of the box. In this tutorial I'll show you how to create a single page app in Rails from scratch using remote elements and Stimulus.

![Demo](/assets/images/posts/rails-remote-elements-tutorial/demo.gif)

## Formula

### Stimulus Controller

```javascript
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["error", "form"];
  static values = {
    target: String,
    action: { type: String, default: "replace" },
  };

  connect() {
    this.target =
      this.hasTargetValue && document.querySelector(this.targetValue);
    this.action = this.hasActionValue && this.actionValue;
    this.actions = [
      "afterbegin",
      "afterend",
      "beforebegin",
      "beforeend",
      "remove",
      "replace",
      "update",
    ];
    this.element.addEventListener("ajax:error", (event) =>
      this.handleError(event)
    );
    this.element.addEventListener("ajax:success", (event) =>
      this.handleSuccess(event)
    );
  }

  actionIsPermitted(action) {
    if (this.actions.indexOf(action) == -1) {
      throw `data-request-action-value="${action}" is not one of ${this.actions.join(
        ", "
      )}`;
    } else {
      return true;
    }
  }

  clearForm() {
    this.hasFormTarget && this.formTarget.reset();
  }

  clearErrors() {
    this.hasErrorTarget && (this.errorTarget.innerHTML = "");
  }

  handleError(event) {
    const { response } = event.detail[2];

    this.errorTarget.innerHTML = response;
  }

  handleSuccess(event) {
    const { response } = event.detail[2];

    this.clearErrors();
    this.clearForm();
    this.actionIsPermitted(this.action) &&
      this.updateTarget(this.action, response);
  }

  updateTarget(action, response) {
    switch (action) {
      case "remove":
        this.target.remove();
        break;
      case "replace":
        const parser = new DOMParser();
        const doc = parser.parseFromString(response, "text/html");
        this.target.replaceWith(doc.body.firstChild);
        break;
      case "update":
        this.target.innerHTML = response;
        break;
      default:
        this.target.insertAdjacentHTML(this.action, response);
    }
  }
}
```

> **What's Going On Here?**
>
> - Rails-ujs dispatches [custom events](https://guides.rubyonrails.org/working_with_javascript_in_rails.html#rails-ujs-event-handlers) on the element creating the request. In our case we specifically listen for `ajax:error` and `ajax:success`. Those responses are returned via `event.detail[2]`.
> - If the request was successful we simply update the DOM with the response according to the value of `this.actionValue`. We limit what actions can be used with `this.actionIsPermitted()`. These values are inspired by [Turbo's seven actions](https://turbo.hotwired.dev/reference/streams#the-seven-actions) and are handled via `this.updateTarget()`.
> - Since a request can come from a button, link, or form we need to conditionally handle rendering errors and clearing form data via `this.clearErrors()` and `this.clearForm()`.

### Remote Element Markup

#### Forms

```erb
<%= form_with(
  local: false,
  data: {
    controller: "request",
    request_target: "form",
    request_target_value: "#some_dom_id",
    request_action_value: "afterbegin | afterend | beforebegin | beforeend | remove | replace | update"
  }) do |form| %>
  <div data-request-target="error"></div>
  ...
<% end %>
```

> **What's Going On Here?**
>
> - We need to add `local: false` to ensure the form will make an AJAX request.
> - The `request_target: "form"` data attribute ensures the form will be cleared via `this.clearForm()`.
> - The `request_target_value` data attribute references an element on the page that will be updated when the response from the server is successful.
> - The `request_action_value` data attribute determines how the `request_target_value` element will be updated when the response from the server is successful.
> - We add `<div data-request-target="error"></div>` so we can render any errors in the form if the object is not valid.

#### Buttons

```erb
<%= button_to(
  remote: true,
  form: {
    data: {
      controller: "request",
      request_target_value: "#some_dom_id",
      request_action_value: "afterbegin | afterend | beforebegin | beforeend | remove | replace | update"
    }
  }
) do %>
  ...
<% end %>
```

> **What's Going On Here?**
>
> - We need to add `remote: true` to ensure the form will make an AJAX request.
> - The `request_target_value` data attribute references an element on the page that will be updated when the response from the server is successful. Note that this is wrapped in `form: { data: {} }` since we need [this value to be set on the form and not the button](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to).
> - The `request_action_value` data attribute determines how the `request_target_value` element will be updated when the response from the server is successful. Note that this is wrapped in `form: { data: {} }` since we need [this value to be set on the form and not the button](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to).

#### Links

```erb
<%= link_to(
  task.title,
  task_path(task),
  remote: true,
  data: {
    controller: "request",
    request_target_value: "#some_dom_id",
    request_action_value: "afterbegin | afterend | beforebegin | beforeend | remove | replace | update"
  }
) %>
```

> **What's Going On Here?**
>
> - We need to add `remote: true` to ensure the request will make an AJAX request.
> - The `request_target_value` data attribute references an element on the page that will be updated when the response from the server is successful.
> - The `request_action_value` data attribute determines how the `request_target_value` element will be updated when the response from the server is successful.

### Controller Responses

#### When Responding With a Partial

```ruby
class TasksController < ApplicationController
  def create
    @task = Task.new(task_params)
    if @task.save
      render @task
    else
      render partial: "layouts/form_errors", locals: {object: @task}, status: :unprocessable_entity
    end
  end
end
```

> **What's Going On Here?**
>
> - This action only returns [partials](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials) instead of a full layout. If the `@task` is saved the server will respond with `app/views/tasks/_task.html.erb`. Otherwise it will respond with `layouts/_form_errors.html.erb`. In either case just the markup from the partial is returned instead of the full document.

#### When Responding With a Layout

```ruby
class TasksController < ApplicationController
  def show
    render layout: !request.xhr?
  end
end
```

> **What's Going On Here?**
>
> - This action will return the full page layout (in this case `app/views/tasks/show.html.erb`) unless the request was an [xhr](https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-xhr-3F) request. If the request was made with xhr then only the content of `app/views/tasks/show.html.erb` will be returned instead of the full document. We could have set `layout: false` but there could be a case where we actually visit the route (https://www.example.com/tasks/1). If we set `layout: false` then the response would be missing the actually page layout.

## Example

Below is a real world example of how you can use remote elements to create a single page application in Rails.

**Notes**

- Since it's a single page app, all requests are coming from the root path (`tasks#index`).
- The back button won't work as expected. For example, if you click on a task and then click the back button, you won't be brought back to the `tasks#index` since you're technically already there. Instead you'll be brought back to whatever page you were on last. This is why there are client side routing libraries such as [React Router](https://reactrouter.com/).
- In order to DRY up our code, we set the data attributes for some of the form partials in our controllers since we sometimes respond with a form partial. A good example of this is `tasks#edit` and `app/views/tasks/_form.html.erb`.

### Routes

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root to: "tasks#index"
  resources :tasks, except: [:new] do
    resources :items do
      collection do
        put "mark_all_as_complete"
        put "mark_all_as_incomplete"
      end
    end
  end
end
```

### Layout

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Rails Remote Elements Tutorial</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
  </head>

  <body>
    <main class="container-sm my-5">
      <div class="row justify-content-center">
        <div class="col col-5" id="content">
          <%= yield %>
        </div>
      </div>
    </main>
  </body>
</html>
```

```erb
<!--  app/views/layouts/_form_errors.html.erb -->
<div class="alert alert-danger" role="alert">
  <ul class="mb-0">
    <% object.errors.full_messages.each do |error| %>
      <li><%= error %></li>
    <% end %>
  </ul>
</div>
```

### Task Controller and Views

```ruby
# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :set_task, except: [:create, :index]
  before_action :set_new_item_data_attributes, only: [:show]
  before_action :set_edit_task_data_attributes, only: [:edit]
  before_action :set_new_task_data_attributes, only: [:index]

  def create
    @task = Task.new(task_params)
    if @task.save
      render @task
    else
      render partial: "layouts/form_errors", locals: {object: @task}, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
  end

  def edit
    render partial: "form", locals: {data_attributes: @edit_task_data_attributes}
  end

  def index
    @tasks = Task.all.order(created_at: :desc)
    @task = Task.new
    render layout: !request.xhr?
  end

  def show
    @items = @task.items.order(created_at: :desc)
    render layout: !request.xhr?
  end

  def update
    if @task.update(task_params)
      render @task
    else
      render partial: "layouts/form_errors", locals: {object: @task}, status: :unprocessable_entity
    end
  end

  private

  def set_new_item_data_attributes
    @new_item_data_attributes = {
      controller: "request",
      request_target: "form",
      request_target_value: "#items",
      request_action_value: "afterbegin"
    }
  end

  def set_new_task_data_attributes
    @new_task_data_attributes = {
      controller: "request",
      request_target: "form",
      request_target_value: "#tasks",
      request_action_value: "afterbegin"
    }
  end

  def set_edit_task_data_attributes
    @edit_task_data_attributes = {
      controller: "request",
      request_target: "form",
      request_target_value: "#task_#{@task.id}",
      request_action_value: "replace"
    }
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title)
  end
end
```

```erb
<!-- app/views/tasks/_form.html.erb -->
<%= form_with model: @task, local: false, data: data_attributes, class: "row align-items-center" do |form| %>
  <div data-request-target="error">
    <%= render partial: "layouts/form_errors", locals: { object: form.object } if form.object.errors.any? %>
  </div>
  <div class="col-9">
    <%= form.text_field :title, class: "form-control" %>
  </div>
  <div class="col-3">
    <%= form.submit class: "btn btn-primary" %>
  </div>
<% end %>
```

```html
<!-- app/views/tasks/_task.html.erb -->
<li
  class="list-group-item list-group-item d-flex justify-content-between align-items-center"
  id="<%= dom_id(task) %>"
>
  <%= link_to task.title, task_path(task), class: "fs-5 link-dark", remote:
  true, data: { controller: "request", request_target_value: "#content",
  request_action_value: "update" } %>
  <div>
    <%= link_to "Edit", edit_task_path(task), class: "link-secondary", remote:
    true, data: { controller: "request", request_target_value:
    "##{dom_id(task)}", request_action_value: "update" } %> <%= link_to
    "Delete", task_path(task), class: "link-secondary", method: :delete, remote:
    true, data: { controller: "request", request_target_value:
    "##{dom_id(task)}", request_action_value: "remove" } %>
  </div>
</li>
```

```erb
<!-- app/views/tasks/index.html.erb -->
<%= render partial: "form", locals: { data_attributes: @new_task_data_attributes } %>
<ul id="tasks" class="mt-4 list-group list-group-flush">
  <%= render @tasks %>
</ul>
```

```erb
<!-- app/views/tasks/show.html.erb -->
<%= link_to "Back to Tasks", tasks_path, remote: true, data: { controller: "request", request_target_value: "#content", request_action_value: "update" } %>
<h1><%= @task.title %></h1>
<div class="mb-4">
  <%= render partial: "items/form", locals: { object: [@task, @task.items.build], data_attributes: @new_item_data_attributes } %>
</div>
<div class="row gx-2">
  <%= button_to "Mark All As Complete", mark_all_as_complete_task_items_path(@task), method: :put, remote: true, form_class: "col-4", class: "btn btn-sm btn-outline-secondary", form: { data: { controller: "request", request_target_value: "#items-container", request_action_value: "update"  } }  %>
  <%= button_to "Mark All As Incomplete", mark_all_as_incomplete_task_items_path(@task), method: :put, remote: true, form_class: "col-4", class: "btn btn-sm btn-outline-secondary", form: { data: { controller: "request", request_target_value: "#items-container", request_action_value: "update"  } }  %>
</div>
<div id="items-container">
  <%= render partial: "items/items" %>
</div>
```

### Item Controller and Views

```ruby
# app/controllers/items_controller.rb
class ItemsController < ApplicationController
  before_action :set_item, only: [:destroy, :edit, :update]
  before_action :set_task
  before_action :set_edit_item_data_attributes, only: [:edit]

  def create
    @item = @task.items.build(item_params)
    if @item.save
      render @item
    else
      render partial: "layouts/form_errors", locals: {object: @item}, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
  end

  def edit
    render partial: "form", locals: {object: [@task, @item], data_attributes: @edit_item_data_attributes}
  end

  def mark_all_as_complete
    @items = @task.items.order(created_at: :desc)
    @items.update_all(complete: true)
    render partial: "items"
  end

  def mark_all_as_incomplete
    @items = @task.items.order(created_at: :desc)
    @items.update_all(complete: false)
    render partial: "items"
  end

  def update
    if @item.update(item_params)
      render @item
    else
      render partial: "layouts/form_errors", locals: {object: @item}, status: :unprocessable_entity
    end
  end

  private

  def item_params
    params.require(:item).permit(:title, :complete)
  end

  def set_edit_item_data_attributes
    @edit_item_data_attributes = {
      controller: "request",
      request_target: "form",
      request_target_value: "#item_#{@item.id}",
      request_action_value: "replace"
    }
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def set_task
    @task = Task.find(params[:task_id])
  end
end
```

```erb
<!-- app/views/items/_form.html.erb -->
<%= form_with model: object, local: false, data: data_attributes, class: "row align-items-center" do |form| %>
  <div data-request-target="error">
    <%= render partial: "layouts/form_errors", locals: { object: form.object } if form.object.errors.any? %>
  </div>
  <div class="col-9">
    <%= form.text_field :title, class: "form-control" %>
  </div>
  <div class="col-3">
    <%= form.submit class: "btn btn-primary"%>
  </div>
<% end %>
```

```erb
<!--  app/views/items/_item.html.erb -->
<% unless item.new_record? %>
  <li class="list-group-item list-group-item d-flex justify-content-between align-items-center" id="<%= dom_id(item) %>">
    <div class="d-flex justify-content-between align-items-center">
      <%= item.title %>
      <%= button_to [item.task, item], class: "btn btn-link", method: :put, remote: true, params: { item: { complete: !item.complete } }, form: { data: { controller: "request", request_target_value: "##{dom_id(item)}", request_action_value: "replace" }  } do %>
        <%= item.complete? ? "Mark as incomplete" : "Mark as complete" %>
      <% end %>
    </div>
    <div>
      <%= link_to "Edit", edit_task_item_path(item.task, item), class: "link-secondary", remote: true, data: { controller: "request", request_target_value: "##{dom_id(item)}", request_action_value: "update" } %>
      <%= link_to "Delete", task_item_path(item.task, item), class: "link-secondary", method: :delete, remote: true, data: { controller: "request", request_target_value: "##{dom_id(item)}", request_action_value: "remove" } %>
    </div>
  </li>
<% end %>
```

```erb
<!-- app/views/items/_items.html.erb -->
<ul id="items" class="mt-4 list-group list-group-flush">
  <%= render @items %>
</ul>
```
