---
title: "Lazy Load Content in Rails from Scratch"
og_image: https://mugshotbot.com/m/KLdPfuCm
date: "2021-10-16"
categories: ["Ruby on Rails"]
resources: [
  {
    title: "Source Code",
    url: "https://github.com/stevepolitodesign/rails-lazy-load-content-from-scratch"
  },
  {
    title: "Lazy-loading content with Turbo Frames and skeleton loader",
    url: "https://boringrails.com/tips/turboframe-lazy-load-skeleton"
  },
  {
    title: "Building GitHub-style Hovercards with StimulusJS and HTML-over-the-wire",
    url: "https://boringrails.com/articles/hovercards-stimulus/"
  },  
]
---

Are certain pages on your Rails app loading slowly? You might want to consider loading those requests in the background. It's easier than you think. In this tutorial I'll show you how to lazy load content in Rails without Hotwire.

![Demo](/assets/images/posts/lazy-load-content-in-rails-from-scratch/demo.gif)

## Formula

1. Create an endpoint that does not return a layout.

```ruby
class LazyLoad::PostsController < ApplicationController
  def index
    @posts = Post.all
    render partial: "lazy_load/posts/post", collection: @posts, layout: false
  end
end
```

2. Add a [placeholder](https://getbootstrap.com/docs/5.1/components/placeholders/#example) element onto the page that will represent where the content will be loaded.

```html
<div data-controller="lazy-load" data-lazy-load-url-value="<%= lazy_load_posts_path %>">
  <div data-lazy-load-target="output" class="d-grid gap-3">
    <%= render partial: "shared/placeholder" %>
  </div>
</div>
```

3. Make a [Fetch request](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch) to the endpoint and replace the placeholder with the response from the endpoint.

```js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["output"];
  static values = { url: String };

  connect() {
    this.request = new Request(this.urlValue)
    this.fetchContent(this.request);
  }

  fetchContent(request) {
    fetch(request)
      .then((response) => {
        if (response.status === 200) {
          response.text().then((text) => (this.renderContent(text)));
        } else {
          this.renderContent("Could not load data");
        }
      })
      .catch((error) => {
        this.renderContent("Could not load data");
      });
  }

  renderContent(content) {
    this.outputTarget.innerHTML = content
    this.dispatchEvent("lazy_load:complete")
  }

  dispatchEvent(eventName) {
    const event = new Event(eventName);
    document.dispatchEvent(event);
  }

}
```

## Example

### Step 1: Create Endpoints

1. Generate namespaced controllers.

```bash
rails g controller lazy_load/posts
rails g controller lazy_load/users
```

2. Add namespaced routes with default values.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  ...
  namespace :lazy_load do
    defaults layout: false do
      resources :posts, only: [:index]
      resources :users, only: [:index]
    end
  end
end
```

3. Build controller actions.

```ruby
# app/controllers/lazy_load/posts_controller.rb
class LazyLoad::PostsController < ApplicationController
  def index
    @posts = Post.all
    render partial: "lazy_load/posts/post", collection: @posts
  end
end
```

```ruby
# app/controllers/lazy_load/posts_controller.rb
class LazyLoad::UsersController < ApplicationController
  def index
    @users = User.all
    render partial: "lazy_load/users/user", collection: @users
  end
end
```

4. Build views.

#### Card 

```html
# app/views/shared/_card.html.erb
<div class="card">
  <div class="card-body">
    <h5 class="card-title"><%= title %></h5>
    <p class="card-text"><%= body %></p>
    <p class="card-text"><small class="text-muted"><%= timestamp %></small></p>
  </div>
</div>
```

#### Placeholder Card Variant

```html
# app/views/shared/_card.html+empty.erb
<div class="card mb-3">
  <div class="card-body">
    <p aria-hidden="true" class="d-grid gap-3 placeholder-glow">
      <span class="placeholder col-12 placeholder-lg"></span>
      <span class="placeholder col-6"></span>
      <span class="placeholder col-6 placeholder-xs"></span>
    </p>
  </div>
</div>
```
#### List Group

```html
# app/views/shared/_list_group.html.erb
<li class="list-group-item d-flex justify-content-between align-items-start">
  <div class="ms-2 me-auto">
    <div class="fw-bold"><%= name %></div>
    <%= email %>
  </div>
  <a href="#" data-bs-toggle="tooltip" data-bs-placement="top" title="<%= tooltip %>">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-info-circle" viewBox="0 0 16 16">
      <path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
      <path d="m8.93 6.588-2.29.287-.082.38.45.083c.294.07.352.176.288.469l-.738 3.468c-.194.897.105 1.319.808 1.319.545 0 1.178-.252 1.465-.598l.088-.416c-.2.176-.492.246-.686.246-.275 0-.375-.193-.304-.533L8.93 6.588zM9 4.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0z"/>
    </svg>
  </a>  
</li>
```
#### Post

```html
# app/views/lazy_load/posts/_post.html.erb
<%= render partial: "shared/card", locals: { title: post.title, body: post.body, timestamp: time_ago_in_words(post.updated_at) } %>
```
#### User
```html
# app/views/lazy_load/users/_user.html.erb
<%= render partial: "shared/list_group", locals: { name: user.name, email: user.email, tooltip: pluralize(user.posts.size, 'Post')  } %>
```

> **What's Going On Here?**
> 
> - We create a [namespaced route and controller](https://guides.rubyonrails.org/routing.html#controller-namespaces-and-routing). This isn't required, but it helps keep our endpoints organized. We're also not limited to just `index` actions either.
> - We set a [default](https://guides.rubyonrails.org/routing.html#defining-defaults) for those endpoints to [not render a layout](https://guides.rubyonrails.org/layouts_and_rendering.html#options-for-render). This means that just the raw HTML for the partials will be returned.
> - We choose to create custom views for each endpoint, but we could use the existing views or partials if we wanted to. This is just personal preference.

If you navigate to [http://localhost:3000/lazy_load/users](http://localhost:3000/lazy_load/users) you should see that the content has loaded without a layout.

![Web response](/assets/images/posts/lazy-load-content-in-rails-from-scratch/web_response.png)

If you open the network tab you will see that the server responded with raw HTML without a layout.

![Newtork response](/assets/images/posts/lazy-load-content-in-rails-from-scratch/network_response.png)

### Step 2: Build a Stimulus Controller

1. Create a Stimulus Controller to fetch data from the endpoints.

```js
// app/javascript/controllers/lazy_load_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["output"];
  static values = { url: String };

  connect() {
    this.request = new Request(this.urlValue)
    this.fetchContent(this.request);
  }

  fetchContent(request) {
    fetch(request)
      .then((response) => {
        if (response.status === 200) {
          response.text().then((text) => (this.renderContent(text)));
        } else {
          this.renderContent("Could not load data");
        }
      })
      .catch((error) => {
        this.renderContent("Could not load data");
      });
  }

  renderContent(content) {
    this.outputTarget.innerHTML = content
    this.dispatchEvent("lazy_load:complete")
  }

  dispatchEvent(eventName) {
    const event = new Event(eventName);
    document.dispatchEvent(event);
  }

}
```

2. Use the following markup to connect to the Stimulus Controller.

```html
<div data-controller="lazy-load" data-lazy-load-url-value="<%= lazy_load_users_path %>">
  <div data-lazy-load-target="output" class="d-grid gap-3">
    <% 5.times do |i| %>
      <%= render partial: "shared/card", variants: [:empty] %>
    <% end %>
  </div>
</div>
```

> **What's Going On Here?**
> 
> - We could just use vanilla JavaScript instead of [Stimulus](https://stimulus.hotwired.dev/), but Stimulus pairs nicely with Rails and will make it easy to get up and running with this feature quickly.
> - When the Stimulus Controller first connects, it will make a [fetch request](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) to whatever value is stored in the `data-lazy-load-url-value` attribute. This keeps our Stimulus Controller flexible and reusable.
> - If the request was successful we replace the placeholder with the response. Note that we call [response.text()](https://developer.mozilla.org/en-US/docs/Web/API/Request/text) in order to return the response into a String.
> - If the request was not successful, we simply replace the placeholder with an error message.
> - In all cases we [dispatch a custom event](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/dispatchEvent) on the `document`. We could call this event anything we want, but it's helpful to namespace it to avoid naming collisions with other libraries or specs. This is what [Rails UJS](https://github.com/rails/rails/commit/ad3a47759e67a411f3534309cdd704f12f6930a7#diff-d4469d4947657c8f2640db112c7ab2ec70c5ef16e4d49a16ee457a9a857da01cR68) does, and is helpful in cases where you need to re-initialize JavaScript for elements that were just added to the DOM. In our case this is helpful for re-initializing tooltips.

```js
// app/javascript/controllers/application.js
document.addEventListener("lazy_load:complete", function() {
  initilizeToolTips();
});

function initilizeToolTips() {
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  });
}
```

### Step 2: Putting it all Together

1. Create a new Controller.

```
rails g controller Homescreens show
```

2. Update the routes.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root to: "homescreens#show"
  resource :homescreen, only: :show
  ...
end
```

3. Add markup to lazy load content users and posts.

```html
# app/views/homescreens/show.html.erb
<div data-controller="lazy-load" data-lazy-load-url-value="<%= lazy_load_posts_path %>">
  <div data-lazy-load-target="output" class="d-grid gap-3">
    <% 5.times do |i| %>
      <%= render partial: "shared/card", variants: [:empty] %>
    <% end %>
  </div>
</div>

<% content_for :left_column do %>
  <div data-controller="lazy-load" data-lazy-load-url-value="<%= lazy_load_users_path %>">
    <ul data-lazy-load-target="output" class="list-group list-group-flush list-unstyled">
      <% 5.times do |i| %>
        <li><%= render partial: "shared/card", variants: [:empty] %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```
