---
title: Are you absolutely sure your Rails caching strategy isn't leaking sensitive information?
excerpt: Rails writes a new cache entry based on the first request. But what happens when that request is from an admin?
categories: ["Ruby on Rails"]
tags: ["Security"]
canonical_url: https://thoughtbot.com/blog/rails-caching-risks
---

Imagine we have a partial that renders a product's attributes. If the person
viewing the product is an admin, we render an additional set of attributes not
intended for the general public to see.

```erb
<% # app/views/products/_product.html.erb %>
<div id="<%= dom_id product %>">
  <h2><%= product.name %></h2>
  <p>
    <strong>Price:</strong>
    <%= product.price_in_cents.to_fs(:currency) %>
  </p>
  <% # data intended for admins only %>
  <% if admin? %>
    <p>
      <strong>Wholesale price:</strong>
      <%= product.wholesale_price_in_cents.to_fs(:currency) %>
    </p>

    <p>
      <strong>Supplier:</strong>
      <%= product.supplier %>
    </p>
  <% end %>
</div>
```

In an effort to improve performance, we use [fragment caching][1] to cache each
product on the page.

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= render product %>
  <% end %>
<% end %>
```

When your application receives its first request to this page, Rails will write
a new cache entry.

Unfortunately, this means that if the first request comes from an admin, the
cache will be written using values **not** intended for the general public to
see.

![A list of products as seen by a non-admin where attributes intended for the
admin are visible](https://images.thoughtbot.com/6uh6tn7t3fp7z0pl9ecdakga3m17_example.png)

One way to prevent this is to call [uncacheable!][2] inside the partial.

```diff
  <% # app/views/products/_product.html.erb %>
+ <% uncacheable! if admin? %>
  <div id="<%= dom_id product %>">
    <h2><%= product.name %></h2>
    <p>
      <strong>Price:</strong>
      <%= product.price_in_cents.to_fs(:currency) %>
    </p>
    <% # data intended for admins only %>
    <% if admin? %>
      <p>
        <strong>Wholesale price:</strong>
        <%= product.wholesale_price_in_cents.to_fs(:currency) %>
      </p>

      <p>
        <strong>Supplier:</strong>
        <%= product.supplier %>
      </p>
    <% end %>
  </div>
```

Now if the first request is made by an admin, the application will raise
`UncacheableFragmentError`.

![An error screen showing UncacheableFragmentError is raised](https://images.thoughtbot.com/4hcejqb6utd0eyu8yy95716eo94a_raised.png)

Although this will prevent the cache from being written, it also breaks the
application for that admin. An improvement is to conditionally write to the
cache based on if the request came from an admin by using [cache_unless?][3].

```diff
<% @products.each do |product| %>
- <% cache product do %>
+ <% cache_unless admin?, product do %>
    <%= render product %>
  <% end %>
<% end %>
```

Now if the **first** request is made by an admin, we do not cache the result.
We only cache the result once the first request comes from a non-admin.

![The same list of products as seen by a non-admin. This time, the attributes
intended for the admin are no longer visible](https://images.thoughtbot.com/i771u3dtlh5ffk0hdn285qxsar85_solution.png)

An alternative approach is to pass both dependencies as part of an array.

```diff
<% @products.each do |product| %>
- <% cache product do %>
+ <% cache [product, admin?] do %>
    <%= render product %>
  <% end %>
<% end %>
```

If the product is updated, or the value of `admin?` changes, then the cache will
be broken.

The same vulnerability exists for [collection caching][4] too. If an admin
makes the **first** request to the page, the cache will be written with data
intended for an admin.

```erb
<%= render partial: 'products/product', collection: @products, cached: true %>
```

Unfortunately, calling `uncacheable!` has no effect here since we are no longer
using a `cache` block.

Instead, we can scope the cache to multiple dependencies like we did with the
previous fragment cache implementation.

```erb
<%= render partial: 'products/product', collection: @products, cached: -> product { [ product, admin? ] }%>
```

[1]: https://guides.rubyonrails.org/caching_with_rails.html#fragment-caching
[2]: https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-uncacheable-21
[3]: https://api.rubyonrails.org/classes/ActionView/Helpers/CacheHelper.html#method-i-cache_unless
[4]: https://guides.rubyonrails.org/caching_with_rails.html#collection-caching
