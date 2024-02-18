---
title: Rails advanced routing constraints
excerpt: Learn how to authorize requests at the routing layer to improve security and ergonomics.
categories: ["Ruby on Rails"]
tags: ["Security"]
canonical_url: https://thoughtbot.com/blog/rails-advanced-routing-constraints
---

I'm on a client project that's using [Devise][]. In an effort to prevent
anonymous users from accessing admin routes, we wrap those routes with an
[authenticated][] constraint. This constraint also ensures only authenticated
users who are admins are allowed access.

```ruby
# config/routes.rb

authenticated :user, -> { _1.admin? } do
  namespace :admin do
    resources :users
  end
end
```

[Devise]: https://github.com/heartcombo/devise
[authenticated]: https://rubydoc.info/gems/devise/ActionDispatch/Routing/Mapper#authenticated-instance_method

We recently needed to restrict access to the admin routes based on IP address.
Our first approach was to place this logic at the controller layer and use a
[before_action][] [filter][].

```ruby
# app/controllers/admin/users_controller.rb

class Admin::UsersController < ApplicationController
  before_action :authorize_ip

  private

  def authorize_ip
    allow_list = Rails.application.config.x.ips.allow_list

    raise ActionController::RoutingError.new("Not Found") unless requests.ip.in? allow_list
  end
end
```

However, we realized there was an opportunity to push this logic to the routing
layer, since we already have access to the [request][] object. This saves us from
having to process the request in a controller altogether, which is a small
performance gain.

[before_action]: https://api.rubyonrails.org/classes/AbstractController/Callbacks/ClassMethods.html#method-i-before_action
[filter]: https://guides.rubyonrails.org/action_controller_overview.html#filters
[request]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html

## Create a custom constraint

Although Rails provides the ability to [restrict routes based on IP range][2],
we needed to create a [custom constraint][3] in order to see if the IP was in our
allow list, which is not possible otherwise.

The custom constraint needs to respond to `matches?` when passed a [request][1],
and must return a boolean.

To see if a request is from an IP address in our allow list, we can do something
like this:

```ruby
# app/constraints/ip_constraint.rb

class IpConstraint
  def self.matches?(request)
    allow_list = Rails.application.config.x.ips.allow_list

    request.ip.in? allow_list
  end
end
```

Then we can wrap our admin routes in this constraint like so.

```ruby
# config/routes.rb

authenticated :user, -> { _1.admin? } do
  constraints(IpConstraint) do
    namespace :admin do
      resources :users
    end
  end
end
```

[1]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
[2]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints-label-Restricting+based+on+IP
[3]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints-label-Dynamic+request+matching

## Consolidating constraints

Although the previous implementation is perfectly acceptable, there's an
opportunity to consolidate the [authenticated][] constraint with our
`IpConstraint`.

Since we need access to the `user`, we can leverage [warden][] (which is a
dependency of Devise) to return the user object from the [request][].

```ruby
requst.env["warden"].user

# => #<User>
```

We can then combine this with the logic used to check the IP address like so:

```ruby
# app/constraints/admin_constraint.rb

class AdminConstraint
  attr_reader :user, :ip

  def initialize(request)
    @user = request.env["warden"].user
    @ip = request.ip
  end

  def self.matches?(request)
    new(request).authorized?
  end

  def authorized?
    allow_list = Rails.application.config.x.ips.allow_list

    ip.in?(allow_list) && user.present? && user.admin?
  end
end
```

A constraint needs to respond to `matches?`, so we are free to put whatever
logic we want in that method so long as it returns boolean. In this
case, our `matches?` method initializes a new instance of our constraint and
calls `authorized?`. The `authorized?` method is responsible for determining if
the request came from a supported IP address, and that the requested came from
an authenticated admin.

Now we can update our routes like so:

```ruby
# config/routes.rb

constraints(AdminConstraint) do
  namespace :admin do
    resources :users
  end
end
```

[authenticated]: https://rubydoc.info/gems/devise/ActionDispatch/Routing/Mapper#authenticated-instance_method
[warden]: https://github.com/wardencommunity/warden/wiki/Overview#the-how
[request]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html

## Wrapping up

I think this is an appropriate strategy for authorizing requests at the routing
layer (instead of the controller layer) because it is only concerned with data
in the [request][].

If you need data beyond the raw request, then you should leverage authorization
libraries such as [Pundit][].

[Pundit]: https://github.com/varvet/pundit
[request]: https://api.rubyonrails.org/classes/ActionDispatch/Request.html
