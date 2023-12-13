---
title: Speed up your Rack application with HTTP
excerpt: You don't need a sophisticated caching mechanism to improve your
  application's performance. All you need is a basic understanding of the
  HTTP specification.
categories: ["Ruby"]
tags: ["Rack", "Tutorial"]
canonical_url: https://thoughtbot.com/blog/ruby-rack-performance-improvements-tutorial
---

If you're like me, then you probably take application caching and performance
improvements for granted because you rely on a web framework like Rails to do
this for you. Although this level of abstraction is helpful, it can also obscure
the underlying mechanisms, making it challenging to diagnose issues or further
optimize your application.

In this tutorial, we'll learn how to leverage [HTTP][1] to improve the
performance of a simple [Rack application][2] in an effort to demystify the
intricacies of caching strategies and performance enhancement at the
foundational level. If you want to learn more about the [Rack application][2],
feel free to read our [pragmatic guide to building a Rack application from
scratch][21].

Below is a simplified version of [our application's][2] `config.ru` file from
which we will be working with. If at any time you wish to explore on your own,
feel free to review the [commit history][3].

```ruby
require_relative "app/app"

app = Rack::Builder.new do
  use Rack::Static,
    root: "public",
    urls: ["/css"],
  run App.new
end

run app
```

## Caching

Since our application's style sheet is not likely to frequently change, it's the
perfect candidate for [HTTP Caching][4]. This is even confirmed by a [Lighthouse
Performance Audit][5] which suggests we serve static assets with an [effective
caching strategy][6].

![In image of a Lighthouse Performance violation. It says our styles.css file is
not
cached.](https://images.thoughtbot.com/ou0afb5scf6udfkgvs8riurm6lck_cache_before.png)

Since we're using [Rack::Static][7], we can easily resolve this by adding custom
header rules for all static files served through our application.

```diff
 require_relative "app/app"

 app = Rack::Builder.new do
   use Rack::Static,
     root: "public",
     urls: ["/css"],
+    header_rules: [
+      [:all, {"Cache-Control" => "public, max-age=31556952"}]
+    ]
   run App.new
 end
```

What this says is that we want to cache our style sheet for 1 year (31556952=
the number of seconds in a year). We also set this cache to `public` since the
style sheet does not contain any user-specific information. This is important
because by using `public`, we're permitting the response to be cached by shared
caches, like a Content Delivery Network (CDN) or a proxy.

If we restart our server and run another performance audit, we'll see that the
violation has been resolved.

![In image of a Lighthouse Performance audit. It says we have no 'Uses efficient
cache policy on static assets'
violations.](https://images.thoughtbot.com/lqhpba7lbo7n1vhch1ctyjhz4ctb_cache_after.png)

## Conditional Requests

You might be thinking that we should set the `Cache-Control` header on server
rendered pages too. Although we could do that, a more effective approach is to
use [HTTP conditional requests][8]. This ensures that the browser's cache can be
used if the response body hasn't changed since the last request.

This works by setting an [ETag][9] to identify the version of a specific
resource (usually by [hashing the response body][10]) and
comparing it to the [If-None-Match][11] header in the request. If the two values
match, then a [304 Not Modified][12] is returned instead of a [200 OK][13].

We could do this manually, but fortunately for us, the [Rack][18] library ships
with [Rack::ConditionalGet][14] to do this for us. All we need to do is add it
to our stack.

```diff
 require_relative "app/app"

 app = Rack::Builder.new do
+  use Rack::ConditionalGet
+  use Rack::ETag
   use Rack::Deflater
   use Rack::Static
     root: "public",
     urls: ["/css"],
```

We can verify that this worked by visiting a server-rendered page in our
application. The first request should result in a [200 OK][13], but any
subsequent request will return a [304 Not Modified][12] (so long as the response
body hasn't changed), resulting in a smaller response size.

**Before**
![An image of a network request in the developer tools. The status is a 200, and
the size is
1.2kB.](https://images.thoughtbot.com/5k0u5vri3ytngg5j9khs7vqp8167_e-tag-before.png)

**After**
![An image of the same network request in the developer tools. This time, the
status is a 304, and the size is only
396B.](https://images.thoughtbot.com/swc15pl7b570uvxv79o61ykc6oq8_e-tag-after.png)

It's worth noting that even though the response size was reduced, the response
time remained the same. This is because the server-side logic used to build the
response body was still invoked in order to compare the headers. If we wanted to
further improve performance, we could store the response in a cache store like
Redis.

```ruby
if (requested_etag = req.headers["If-None-Match"]) && etag_still_warm_in_redis_cache?(requested_etag)
  [304, {}, []]
else
  slow_uncached_action
end
```

We can also verify that the [ETag][9] and [If-None-Match][11] headers are set by
inspecting the request.

![An image of the Response and Request headers viewed from the developer tools.
Both the ETag and If-None-Match headers are set to
W/"26647a614ce7c20db0b774e5b60e089c"](https://images.thoughtbot.com/xw2pgiyp6z8rfo6sqpxm87735oto_e-tag-headers.png)

## Compression

Finally, we can leverage [HTTP Compression][15] to drastically reduce the size
of response documents in an effort to improve performance. We can confirm our
application is not utilizing any sort of compression by running a [Lighthouse
Performance Audit][5].

![In image of a Lighthouse Performance violation. It says Text-based resources
should be served with compression (gzip, deflate or brotli) to minimize total
network
bytes.](https://images.thoughtbot.com/qj2gn40ax0o8o0o8ypp1nk57z49k_compression_before.png)

Luckily, the [Rack library][18] makes implementing this fix effortless with the
[Rack::Deflator][16] middleware (which we've [written about before][17]). All we
need to do is add it to our stack.

```diff
 require_relative "app/app"

 app = Rack::Builder.new do
+  use Rack::Deflater
   use Rack::ConditionalGet
   use Rack::ETag
   use Rack::Static,
     root: "public",
     urls: ["/css"],
```

We can verify that our application is using [HTTP Compression][15] by running
the performance audit again.

![In image of the previous Lighthouse Performance violation. This time it says
text compression is
enabled.](https://images.thoughtbot.com/4zbcq2xs4kv3njfb8d5opb6lbiq9_compression_after.png)

## Wrapping up

The concepts we've discussed aren't specific to [Rack][18] and serve as a
reminder that understanding [HTTP][1] is vital to web application development.

[Rack][18] makes setting these headers easy thanks to its available middleware,
but there's nothing stopping you from [manually setting a response header][19]
in your [Rack compliant][20] application.

[1]: https://developer.mozilla.org/en-US/docs/Web/HTTP
[2]: https://github.com/thoughtbot/resolved
[3]: https://github.com/thoughtbot/resolved/commits/main
[4]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching
[5]: https://developer.chrome.com/docs/lighthouse/performance/
[6]: https://developer.chrome.com/docs/lighthouse/performance/uses-long-cache-ttl/#how-to-cache-static-resources-using-http-caching
[7]: https://rubydoc.info/gems/rack/Rack/Static
[8]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Conditional_requests
[9]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/ETag
[10]: https://github.com/rack/rack/blob/696ed9e8f48053683a0a19fc68eb49f094c0efcb/lib/rack/etag.rb#L58-L66
[11]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-None-Match
[12]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/304
[13]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/200
[14]: https://rubydoc.info/gems/rack/Rack/ConditionalGet
[15]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Compression
[16]: https://rubydoc.info/gems/rack/Rack/Deflater
[17]: https://thoughtbot.com/blog/content-compression-with-rack-deflater
[18]: https://github.com/rack/rack
[19]: https://github.com/rack/rack/blob/main/SPEC.rdoc#the-headers-
[20]: https://github.com/rack/rack/blob/main/SPEC.rdoc#label-Rack+applications
[21]: https://thoughtbot.com/blog/ruby-rack-tutorial
