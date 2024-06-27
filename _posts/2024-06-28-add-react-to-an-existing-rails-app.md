---
title:
  A pragmatic guide for adding React to an existing Rails application (and still
  use Hotwire)
excerpt: >
  For a long time, I thought that using React with Rails was an "all-or-nothing"
  proposition. I'm now realizing that the two can be integrated on a spectrum.
categories: ["Ruby on Rails"]
canonical_url: https://thoughtbot.com/blog/add-react-to-an-existing-rails-app
---

Although [Turbo] and [Stimulus] are incredibly effective for
creating reactive, high-fidelity web applications, there are still times where
you will need to reach for [React]. In our case, this happens when
you're required to build a feature that could easily be solved by an
off-the-shelf solution thanks to React's rich component library ecosystem.

However, you're hesitant to reach for React because you just want to "sprinkle"
it into a page or two. You don't want to abandon Rails defaults or Hotwire, and
you certainly don't want to be bothered with configuring (or maintaining) a
complicated build process.

For a long time, I thought that using React with Rails was an "all-or-nothing"
proposition. I'm now realizing that the two can be integrated on a spectrum. On
one end is something like using an [API only Rails application][api] to power
[Next.js][next]. In the middle is something like [Superglue] or
[Inertia.js][inertia]. And, on the other end, is the ability to add React to a
page or two. This is what we'll focus on today.

If you're interested in learning how to integrate React and Rails on a **new**
project, we've [written][react-rails-article] about that too.

## Our base

For the sake of this tutorial, we'll be working with a default Rails application
spun up simply with `rails new`. This means we'll be starting with
[importmap-rails][importmap], [Turbo] and [Stimulus].

Our application simply renders a list of events, and we've been tasked with
rendering it as a calendar. We've decided to use React for this since it's a
solved problem thanks to [FullCalendar].

![An image of a list of events](https://images.thoughtbot.com/qaibn17bv7zf037jo9mwx3di41am_333709989-7d81bec3-32e0-4210-81fa-6035babe738e.png)

## Remove importmaps

The first thing we'll need to do is remove `importmaps-rails`. Although we
**could** keep it, it's advisable to have a consistent way to compile and manage
**all** our assets.

```
bundle remove importmap-rails
```

We'll then need to remove or modify the following files to undo what was
generated with the [installation script][install script]. The `diff` should look
something like this:

```diff
--- a/app/assets/config/manifest.js
+++ b/app/assets/config/manifest.js
@@ -1,4 +1,2 @@
 //= link_tree ../images
 //= link_directory ../stylesheets .css
-//= link_tree ../../javascript .js
-//= link_tree ../../../vendor/javascript .js
```

```diff
--- a/app/javascript/application.js
+++ b/app/javascript/application.js
@@ -1,3 +0,0 @@
-// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
-import "@hotwired/turbo-rails"
-import "controllers"
```

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -14,7 +14,6 @@
     <link rel="icon" href="/icon.svg" type="image/svg+xml">
     <link rel="apple-touch-icon" href="/icon.png">
     <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
-    <%= javascript_importmap_tags %>
   </head>

   <body>
```

```diff
--- a/bin/importmap
+++ /dev/null
@@ -1,4 +0,0 @@
-#!/usr/bin/env ruby
-
-require_relative "../config/application"
-require "importmap/commands"
```

```diff
--- a/config/importmap.rb
+++ /dev/null
@@ -1,7 +0,0 @@
-# Pin npm packages by running ./bin/importmap
-
-pin "application"
-pin "@hotwired/turbo-rails", to: "turbo.min.js"
-pin "@hotwired/stimulus", to: "stimulus.min.js"
-pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
-pin_all_from "app/javascript/controllers", under: "controllers"
```

```diff
diff --git a/vendor/javascript/.keep b/vendor/javascript/.keep
deleted file mode 100644
index e69de29..0000000
```

## Install jsbundling-rails

Now that we've removed `importmap-rails`, we need a new way to compile and
manage our assets in a way that will also support React. Fortunately, this is
solved by another tool in the Rails ecosystem via [jsbundling-rails][jsbundling].

After much trial and error, I found [esbuild] to be the simplest bundler option,
in that no additional steps were required to get React to work.

```
bundle add jsbundling-rails
bin/rails javascript:install:esbuild
```

### Re-install Turbo and Stimulus

Now that we've updated our bundler, let's add back Turbo and Stimulus so that
they work with esbuild. All we need to do is re-run their installation scripts.

```
bin/rails turbo:install
bin/rails stimulus:install
```

Note that you may need to [manually register][register] existing controllers
like so:

```js
// app/javascript/controllers/index.js
import { application } from "./application";

import HelloController from "./hello_controller";
application.register("hello", HelloController);
```

## Add React

Now that we have a mechanism to bundle React, let's add it.

```
yarn add react react-dom
```

To ensure everything is properly wired, let's add a simple component and render
it to the screen.

```js
// app/javascript/components/app.jsx
import React from "react";
import { createRoot } from "react-dom/client";

// Clear the existing HTML content
document.body.innerHTML = '<div id="app"></div>';

// Render your React component instead
const root = createRoot(document.getElementById("app"));
root.render(<h1>Hello, world</h1>);
```

```diff
--- a/app/javascript/application.js
+++ b/app/javascript/application.js
@@ -1,2 +1,3 @@
 import "@hotwired/turbo-rails"
 import "./controllers"
+import "./components/app"
```

If you run `bin/dev` you should see an updated homepage.

![An image of "Hello, world" printed to the screen](https://images.thoughtbot.com/zsk1op99urfjr4wzwpb255qkgqq0_333710252-0e8efae6-897d-4bce-86a2-61e4eb5cfa0d.png)

## Sprinkle in some React

Now that we've confirmed React works, let's address the original requirement by
adding a calendar. For this tutorial, we'll leverage
[FullCalendar].

```
yarn add @fullcalendar/core \
 @fullcalendar/react \
 @fullcalendar/daygrid
```

Rather than create an API for the component to digest, let's just return the
`@events` as `JSON` directly on the page. I recognize that this may not be
appropriate for all use cases, but if you have a small record set, this is a
perfectly reasonable (dare I say preferable) approach.

```erb
<%# app/views/events/index.html.erb %>

<script id="events" type="application/json">
  <%= raw @events.to_json %>
</script>

<div id="app"><div>
```

Now that we've added our data source and an element for React to mount on, we
can create a component for our calendar.

```js
// app/javascript/components/calendar.jsx

import React, { useState, useEffect } from "react";
import FullCalendar from "@fullcalendar/react";
import dayGridPlugin from "@fullcalendar/daygrid";

export default function Calendar() {
  const [events, setEvents] = useState([]);

  useEffect(() => {
    const scriptTag = document.getElementById("events");

    if (scriptTag) {
      const data = JSON.parse(scriptTag.textContent.trim());
      setEvents(data);
    }
  }, []);
  return (
    <FullCalendar
      plugins={[dayGridPlugin]}
      initialView="dayGridMonth"
      weekends={true}
      events={events}
    />
  );
}
```

Now we just need to update our base app.

```diff
--- a/app/javascript/components/app.jsx
+++ b/app/javascript/components/app.jsx
@@ -1,9 +1,14 @@
 import React from "react";
 import { createRoot } from "react-dom/client";
+import Calendar from "./calendar";

-// Clear the existing HTML content
-document.body.innerHTML = '<div id="app"></div>';
+export default function App() {
+  return <Calendar />;
+}

-// Render your React component instead
-const root = createRoot(document.getElementById("app"));
-root.render(<h1>Hello, world</h1>);
+const app = document.getElementById("app")
+
+if (app) {
+  const root = createRoot(app);
+  root.render(<App />);
+}
```

If you reload the homepage, you should see the calendar. However, if we
navigate back and forth from the page, we'll see the calendar disappears.

![Navigating between pages wipes the calendar clean](https://images.thoughtbot.com/3kgv7cc13sc6pkuvd72vl1n6v89o_CleanShot%202024-06-27%20at%2010.38.04.gif)

## Account for Turbo Drive

The reason the calendar disappears is because we're not creating a full-page
refresh when we navigate back and forth from the page. Instead, [Turbo
Drive][turbo-drive] is replacing the contents of the requesting document’s `<body>`
with the contents of the response document’s `<body>`. Since the calendar is
generated client-side, it's not part of the response.

In order to account for this, we can simply listen for the [turbo:load][] event
before mounting our calendar. Then, we can listen for the [turbo:before-visit][]
event to unmount our calendar as we navigate away from the page.

```diff
--- a/app/javascript/components/app.jsx
+++ b/app/javascript/components/app.jsx
@@ -6,9 +6,15 @@ export default function App() {
   return <Calendar />;
 }

-const app = document.getElementById("app");
+document.addEventListener("turbo:load", () => {
+  const app = document.getElementById("app");

-if (app) {
-  const root = createRoot(app);
-  root.render(<App />);
-}
+  if (app) {
+    const root = createRoot(app);
+    root.render(<App />);
+
+    document.addEventListener("turbo:before-visit", () => {
+      root.unmount();
+    });
+  }
+});
```

Now, if we navigate back-and-forth we'll see that the calendar loads as
expected.

![Navigating between pages persists the calendar](https://images.thoughtbot.com/sjn16zgrqk7e5028zdjl4f8q04g0_CleanShot%202024-06-27%20at%2010.40.09.gif)

## Wrapping up

So, what did we accomplish? Well, a lot. We were able to quickly and effectively
introduce React to our Rails application without having to introduce a
complicated build process or craft an API. Best of all, we now have a foundation
to add additional React components if needed while still being able to use Turbo
and Stimulus for everything else.

By the way, if you resonated with some of the concepts and approaches in the
article, you might enjoy [Superglue][superglue-article].

[api]: https://guides.rubyonrails.org/api_app.html
[esbuild]: https://esbuild.github.io
[fullcalendar]: https://fullcalendar.io/docs/react
[importmap]: https://github.com/rails/importmap-rails
[inertia]: https://inertiajs.com
[install script]: https://github.com/rails/importmap-rails/blob/main/lib/install/install.rb
[jsbundling]: https://github.com/rails/jsbundling-rails
[next]: https://nextjs.org
[react]: https://react.dev
[register]: https://stimulus.hotwired.dev/reference/controllers#registering-controllers-manually
[stimulus]: https://stimulus.hotwired.dev
[superglue]: https://github.com/thoughtbot/superglue
[turbo]: https://turbo.hotwired.dev
[superglue-article]: https://thoughtbot.com/blog/introducing-superglue
[react-rails-article]: https://thoughtbot.com/blog/how-to-integrate-react-rails
[turbo-drive]: https://turbo.hotwired.dev/handbook/drive#page-navigation-basics
[turbo:load]: https://turbo.hotwired.dev/reference/events#turbo%3Aload
[turbo:before-visit]: https://turbo.hotwired.dev/reference/events#turbo%3Abefore-visit
