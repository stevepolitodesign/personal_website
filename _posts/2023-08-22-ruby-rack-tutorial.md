---
title: A pragmatic guide to building a Rack application from scratch
excerpt: Learn how to build a production ready Rack application without
  a framework like Rails or Sinatra.
categories: ["Ruby"]
tags: ["Rack", "Tutorial"]
canonical_url: https://thoughtbot.com/blog/ruby-rack-tutorial
---

**Confession Time:** Until recently, I didn't really understand what [Rack][]
did. I knew it had _something_ to do with Rails, but I was never in a situation
where I needed to use it directly. Not only that, but I realized that I didn't
actually know how to make a server-side web application from scratch because I
had become so dependent on Rails.

So, I decided to use my [investment
time](https://thoughtbot.com/blog/investment-time) to explore Rack and build
something real. What resulted was [Resolved][]. The application itself is simple
(it just returns a domain's name servers), but the knowledge I gained about the
HTTP specification and other concepts was invaluable.

Here are some of the topics I was forced to understand because they were no
longer abstracted away by Rails (or any other framework). You can get more
context by looking at the [commit history][].

- Rendering dynamic content with `ERB`.
- Using HTTP compression and caching to drastically improve application
  performance.
- Error handling.
- Building a simple logging mechanism.
- HTTP security best practices.
- Configuring a test suite and GitHub Actions from scratch.

Below is what we'll be building in this tutorial.

![An image of a simple web application. There is a form filled out with
https://thoughtbot.com and beneath that are the name servers for
it](https://images.thoughtbot.com/l5c5t70gdtlgr4jp0edslny0eald_1.png)

## Build an initial proof of concept

Before we can begin building something, we'll need to install the [Rack][]
library and [Puma][].

```
bundle add rack puma
```

The Rack library is the mechanism that will handle incoming and outgoing web
requests, and Puma is the mechanism that will serve the Rack application. Note
that there are [other supported web servers][].

Surprisingly, we don't actually need the [Rack][] library to build a [Rack
application][], but we do need it to connect our application to our server as
explained in our [Upcase lesson on Rack][].

> Rack is the underlying technology behind nearly all of the web frameworks in
> the Ruby world.
>
> "Rack" is actually a few different things:
>
> - **An architecture** - Rack defines a very simple interface, and any code
>   that conforms to this interface can be used in a Rack application. This
>   makes it very easy to build small, focused, and reusable bits of code and
>   then use Rack to compose these bits into a larger application.
> - **A Ruby gem** - Rack is distributed as a Ruby gem that provides the glue
>   code needed to compose our code.

With our initial setup out of the way, we can actually begin to build our
application.

Let's start by rendering something simple to the screen. We'll create a [Rack
compliant][] object with a `call` method that takes an `env` argument. The
[env][] argument is a hash representing the current request data.

In order to be [Rack compliant][], an object needs to adhere to this specific
interface. Namely, it should respond to `call` and return an array of three
values:

1. [Status code][]
2. [Headers][]
3. [Response body][]

```ruby
# app/app.rb

class App
  def call(env)
    [200, {}, ["Hello World"]]
  end
end
```

This is exactly what our object does. When a request is made to our application,
our server will respond with a `200` status code, no header information, and a
response body of "Hello World".

Before we can actually view this in a browser, we need to create a `config.ru`
file which [Puma will look for] on boot.

```ruby
# config.ru

require_relative "app/app"

run App.new
```

If we run `bundle exec puma -p 3000` we should be able to navigate to
`http://localhost:3000` and see our simple application.

![An image of "Hello World" rendered as plain text inside a browser
window.](https://images.thoughtbot.com/so7ef7od2i8bth6ts7uv5drwamxi_2.png)

## Create a simple render method

Now that we can render something in the browser, let's introduce a simple render
method inspired by [Rails' render method][].

First, we'll need to create a few [ERB][] templates. We'll start with a basic
layout inspired by [Rails' application layout][].

```erb
<% # app/views/layout.html.erb %>

<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="Find a domain's name servers">
    <title>Resolved</title>
  </head>
  <body>
    <%= @content %>
  </body>
</html>
```

We'll also add another template to act as a [partial][] which will render the
content for the homepage.

```erb
<% # app/views/home.html.erb %>

<p>Enter a domain name</p>
```

Now we can update our application by introducing a method to render our `ERB`
templates.

```diff
 class App
   def call(env)
-    [200, {}, ["Hello World"]]
+    render("home")
+  end
+
+  private
+
+  def render(template, status_code: 200)
+    @content = render_template(template)
+    body = render_template("layout")
+    headers = {"Content-Type" => "text/html; charset=utf-8"}
+
+    [status_code, headers, [body]]
+  end
+
+  def render_template(template)
+    template = File.read("./app/views/#{template}.html.erb")
+    erb = ERB.new(template)
+    erb.result(binding)
   end
 end
```

This works by first rendering our partial, and then assigning it to `@content`,
which will be picked up by the layout. The mechanism responsible for this is
`erb.result(binding)` which encapsulates the context of our code to be used
later. This is similar to how instance variables set in a Rails controller are
then made available in a corresponding view. Note that we also set the headers
to `"text/html; charset=utf-8"`.

If we restart our server and navigate back to `http://localhost:3000` we should
see the new homepage.

![An image of the updated homepage. It now renders an unstyled HTML
document.](https://images.thoughtbot.com/zhv4dz6hv4u4d5csx1apyc94hr25_3.png)

## Handle invalid routes

You might have noticed that no matter what route we visit, we also see the
homepage. This is because we're not actually handling the incoming requests.

Let's fix this by defining a root path, and falling back to a 404-page
otherwise.

```diff
 class App
   def call(env)
-    render("home")
+    req = Rack::Request.new(env)
+    path = req.path_info
+
+    case path
+    when "/"
+      render("home")
+    else
+      handle_missing_path
+    end
   end

   private
@@ -23,4 +31,11 @@ class App
     erb = ERB.new(template)
     erb.result(binding)
   end
+
+  def handle_missing_path
+    body = File.read("./public/404.html")
+    headers = {"Content-Type" => "text/html; charset=utf-8"}
+
+    [404, headers, [body]]
+  end
 end
```

We introduce [Rack::Request][] to make it easier to interface with the `env`
that is passed to our application by adding convenience methods for us, such as
[path_info][].

We'll also need to create a static HTML file for our application to render. We
could do this server-side with our `render` method, but it's more performant to
render a static file. Rails also [renders static files when requests are in the
400 and 500 range][1].

```html
<!-- public/404.html -->

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="description" content="Find a domain's name servers" />
    <title>Resolved</title>
  </head>
  <body>
    <h1>Page not found</h1>
  </body>
</html>
```

Finally, we'll want to introduce [Rack::Static][] so that direct requests to our
404 file will be processed correctly. In order to use `Rack::Static`, we
introduce [Rack::Builder][] to construct our application. If we did not do this,
we would have had to add an additional `when` branch to our `case` statement to
handle direct requests to the `/404.html` path.

```diff
 require_relative "app/app"

-run App.new
+app = Rack::Builder.new do
+  use Rack::Static,
+    root: "public",
+    urls: ["/404.html"],
+    header_rules: [
+      [%w[html], {"Content-Type" => "text/html; charset=utf-8"}],
+    ]
+  run App.new
+end
+
+run app
```

You'll also note that we add a `header_rules` option which sets the
`Content-Type` for all files ending in `.html`. If we restart our application
and visit an invalid route, we'll see the static 404-page, as well as the
correct response.

![An image of a 404-page. The devtools are open, and we can see the status is
404](https://images.thoughtbot.com/yb0gl6tlmkrfjykztp3ihovsgcou_4.png)

If we directly visit our 404-page at `http://localhost:3000/404.html` we'll see
the same layout, but the status will be `200`. This is how [thoughtbot's
404-page][] works, too.

![An image of a 404-page. The devtools are open, and we can see the status is
200](https://images.thoughtbot.com/702zqg4w4m1fjj6imfrfkfex3zlb_5.png)

## Render local variables

Now that we have basic routing, let's begin to build our form. Our initial goal
is to build a simple form that makes a `GET` request. By default, this will add
a query string to the URL with the values set by the form. We'll want that value
to be persisted in the form's input.

First, we'll update our home partial by adding a form with a `url` field.

```diff
 <h1>Resolved</h1>
 <p>Enter a domain name</p>
+<form method="get" action="/">
+  <label for="url">Url</label>
+  <input type="url" name="url" id="url" required value="<%= @locals[:url] %>">
+  <button>Submit</button>
+</form>
```

Next, let's update our `render` method to accept local variables to be used in
our partials.

```diff
     case path
     when "/"
-      render("home")
+      render("home", url: req.params["url"])
     else
       handle_missing_path
     end
@@ -18,7 +18,8 @@ class App

   private

-  def render(template, status_code: 200)
+  def render(template, status_code: 200, **locals)
+    @locals = locals
     @content = render_template(template)
     body = render_template("layout")
     headers = {"Content-Type" => "text/html; charset=utf-8"}
```

We'll leverage the [#params][] helper method to get the value from the form. If
we restart our server and fill out our form, we'll see that the value persists
on the subsequent request.

![Image of a form filled out with https://thoughtbot.com. We can see that the
value is in the address bar as well as the form
itself](https://images.thoughtbot.com/ryvycm7mtnwp37ef0e6g7q74a8gr_6.png)

Now that we have a working form, we can actually implement the logic to return
the name servers.

```diff
     case path
     when "/"
-      render("home", url: req.params["url"])
+      url = req.params["url"]
+
+      if url
+        render("home", url:, name_servers: name_servers_for(url))
+      else
+        render("home")
+      end
     else
       handle_missing_path
     end
@@ -39,4 +47,10 @@ class App

     [404, headers, [body]]
   end
+
+  def name_servers_for(url)
+    host = URI(url).host
+    res = Resolv::DNS.new
+    res.getresources(host, Resolv::DNS::Resource::IN::NS)
+  end
 end
```

```diff
   <input type="url" name="url" id="url" required value="<%= @locals[:url] %>">
   <button>Submit</button>
 </form>
+<% if @locals[:name_servers] %>
+  <p>Name Servers:</p>
+  <ul>
+    <% @locals[:name_servers].each do |name_server| %>
+      <li><%= name_server.name.to_s %></li>
+    <% end %>
+  </ul>
+<% end %>
```

If we restart our server and fill out the form, we'll see that it now returns
name servers.

![The previous form filled out again with https://thoughtbot.com. This time, the
name servers appear on the
page.](https://images.thoughtbot.com/7x9lgk866ejx2iofoee8ed4k4fbc_7.png)

## Render errors

Our application does not yet handle errors. For example, it will break if it's
unable to resolve the name servers for an invalid host.

![An image of a broken homepage. https://thoughtbot.invalid is entered into the
form. The name servers still render but are
blank.](https://images.thoughtbot.com/o7nchie2bp7vtbpba1v5ajeh3nkt_8.png)

We can update `#name_servers_for` to handle errors, and pass the message to
the newly added `announcement` keyword argument on `#render`, which gets assigned to
`@announcement`.

```diff
       url = req.params["url"]

       if url
-        render("home", url:, name_servers: name_servers_for(url))
+        result = name_servers_for(url)
+
+        if result.success
+          render("home", url:, name_servers: result.payload)
+        else
+          render("home", url:, announcement: result.error, status_code: 422)
+        end
       else
         render("home")
       end
@@ -26,8 +32,9 @@ class App

   private

-  def render(template, status_code: 200, **locals)
+  def render(template, status_code: 200, announcement: nil, **locals)
     @locals = locals
+    @announcement = announcement
     @content = render_template(template)
     body = render_template("layout")
     headers = {"Content-Type" => "text/html; charset=utf-8"}
@@ -49,8 +56,17 @@ class App
   end

   def name_servers_for(url)
-    host = URI(url).host
-    res = Resolv::DNS.new
-    res.getresources(host, Resolv::DNS::Resource::IN::NS)
+    result = Struct.new(:success, :payload, :error, keyword_init: true)
+
+    begin
+      host = URI(url).host
+      res = Resolv::DNS.new
+      payload = res.getresources(host, Resolv::DNS::Resource::IN::NS)
+      raise Resolv::ResolvError, "Could not resolve DNS records for #{host}" if payload.empty?
+
+      result.new(success: true, payload: payload)
+    rescue Resolv::ResolvError, URI::InvalidURIError => error
+      result.new(success: false, error: error.message)
+    end
   end
 end
```

Now we just need to update our layout template to include `@announcement`.

```diff
     <title>Resolved</title>
   </head>
   <body>
+    <%= @announcement %>
     <%= @content %>
   </body>
 </html>
```

If we restart our application and fill out the form with an invalid host, we'll
see an error message instead. We also see that we now return a semantically
correct `422` status code.

![An image of a form filled out with https://thoughtbot.invalid. The webpage has
a banner that says it could not resolve DNS records for that host. The devtools
are open, and we can see that the status is
422.](https://images.thoughtbot.com/vxyjgyzq45fvxifjdybqfnebn9s6_11.png)

## Style application

Now that we have a fully functioning application, let's introduce some styles.
We'll use [Bootstrap][] for demonstration purposes.

First, let's update our `Rack::Static` declaration by adding our CSS. While
we're at it, we'll also add a favicon and create a new header rule to ensure all
static assets are cached.

```diff
 app = Rack::Builder.new do
   use Rack::Static,
     root: "public",
-    urls: ["/404.html"],
+    urls: ["/css", "/favicon.ico", "/404.html"],
     header_rules: [
       [%w[html], {"Content-Type" => "text/html; charset=utf-8"}],
+      [:all, {"Cache-Control" => "public, max-age=31536000"}]
     ]
   run App.new
 end
```

Now we can update our application template and 404-page to use the style sheet
and favicon.

```diff
     <meta name="viewport" content="width=device-width, initial-scale=1">
     <meta name="description" content="Find a domain's name servers">
     <title>Resolved</title>
+    <link rel="icon" href="favicon.ico" />
+    <link rel="stylesheet" type="text/css" href="/css/styles.css">
   </head>
 </html>
```

And with that, we should have a fully styled application. We can double-check by
restarting the server.

![An image of a now styled website using default Bootstrap
styles.](https://images.thoughtbot.com/l5c5t70gdtlgr4jp0edslny0eald_1.png)

## Next steps

Although this application is production ready, there are still several things we
can do to [improve its performance and security][], such as compressing and caching
requests and using [HTTP security best
practices](https://developer.mozilla.org/en-US/docs/Web/Security). There's also
an opportunity to improve the developer experience by introducing a logging
mechanism, as well as using a more heuristic error handling mechanism.

If those topics are of interest, you can reference the [source code][] from
which this post was based on in the meantime.

[Rack]: https://github.com/rack/rack
[Puma]: https://puma.io
[Rails' render method]: https://api.rubyonrails.org/v7.0.6/classes/ActionController/Rendering.html#method-i-render
[ERB]: https://docs.ruby-lang.org/en/3.2/ERB.html
[Rails' application layout]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/app/templates/app/views/layouts/application.html.erb.tt
[partial]: https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials
[Rack::Request]: https://rubydoc.info/gems/rack/Rack/Request
[path_info]: https://rubydoc.info/gems/rack/Rack/Request/Helpers#path_info-instance_method
[1]: https://guides.rubyonrails.org/action_controller_overview.html#the-default-500-and-404-templates
[Rack::Static]: https://www.rubydoc.info/gems/rack/Rack/Static
[Rack::Builder]: https://www.rubydoc.info/gems/rack/Rack/Builder
[thoughtbot's 404-page]: https://thoughtbot.com/404.html
[#params]: https://rubydoc.info/gems/rack/Rack/Request/Helpers#params-instance_method
[Bootstrap]: https://github.com/twbs/bootstrap/blob/main/dist/css/bootstrap.min.css
[Resolved]: https://github.com/thoughtbot/resolved
[source code]: https://github.com/thoughtbot/resolved
[commit history]: https://github.com/thoughtbot/resolved/commits/main
[Rack Compliant]: https://github.com/rack/rack/blob/main/SPEC.rdoc
[Status code]: https://github.com/rack/rack/blob/main/SPEC.rdoc#label-The+Status
[Headers]: https://github.com/rack/rack/blob/main/SPEC.rdoc#label-The+Headers
[Response body]: https://github.com/rack/rack/blob/main/SPEC.rdoc#label-The+Body
[env]: https://github.com/rack/rack/blob/main/SPEC.rdoc#label-The+Environment
[Rack application]: https://github.com/rack/rack/blob/main/SPEC.rdoc#label-Rack+applications
[Upcase lesson on Rack]: https://thoughtbot.com/upcase/videos/rack
[other supported web servers]: https://github.com/rack/rack#supported-web-servers
[Puma will look for]: https://github.com/puma/puma#quick-start
[improve its performance and security]: https://thoughtbot.com/blog/ruby-rack-performance-improvements-tutorial
