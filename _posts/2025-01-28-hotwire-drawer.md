---
title: Build a (progressively enhanced) drawer component with Hotwire
excerpt: You can get 90% of the way there with server-rendered templates and View Transitions.
category: ["Ruby on Rails"]
tags: ["Tutorial"]
canonical_url: https://thoughtbot.com/blog/hotwire-drawer
---

In this tutorial, we'll learn how to build a fully animated drawer component
without using any JavaScript. Then, to increase its fidelity, we'll leverage
Hotwire.

![Image of drawer component animating in and out](https://images.thoughtbot.com/x4i3prq8abqoxaxfubhvgs0ogxnq_final.gif)

Feel free to follow along below, or view the [final code][fc] which lives in our
[Hotwire Example Template][het].

[fc]: https://github.com/thoughtbot/hotwire-example-template/compare/main...drawer
[het]: https://github.com/thoughtbot/hotwire-example-template

## Create a faux drawer

Since Hotwire encourages the use of server-rendered templates, why not just make
a page that _looks_ like a drawer?

For our example, we'll use Tailwind CSS to create an application-level partial
to store our drawer component.

```erb
<% #app/views/application/_drawer.html.erb %>
<%# locals: (title: )%>

<div class="relative z-10" aria-labelledby="slide-over-title" role="dialog" aria-modal="true">
  <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
       aria-hidden="true"></div>

  <div class="fixed inset-0 overflow-hidden">
    <div class="absolute inset-0 overflow-hidden">
      <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10">
        <div class="pointer-events-auto relative w-screen max-w-md">
          <div class="absolute left-0 top-0 -ml-8 flex pr-2 pt-4 sm:-ml-10 sm:pr-4">
            <%= link_to :back, class: "relative rounded-md text-gray-300 hover:text-white focus:outline-none focus:ring-2 focus:ring-white" do %>
              <span class="absolute -inset-2.5"></span>
              <span class="sr-only">Close panel</span>
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true" data-slot="icon">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
              </svg>
            <% end %>
          </div>

          <div class="flex h-full flex-col overflow-y-scroll bg-white py-6 shadow-xl">
            <div class="px-4 sm:px-6">
              <h2 class="text-base font-semibold text-gray-900" id="slide-over-title"><%= title %></h2>
            </div>
            <div class="relative mt-6 flex-1 px-4 sm:px-6">
              <%= yield %>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
```

We can even [conditionally render][cr] the drawer template using [variants][var]
in an effort to reuse our existing controller and views.

```erb
<%# app/views/products/edit.html+drawer.erb %>

<%= render "drawer", title: "Edit product" do %>
  <%= render "form", product: @product %>
<% end %>
```

```erb
<%# app/views/products/new.html+drawer.erb %>

<%= render "drawer", title: "New product" do %>
  <%= render "form", product: @product %>
<% end %>
```

```diff
--- a/app/controllers/products_controller.rb
+++ b/app/controllers/products_controller.rb
@@ -1,5 +1,6 @@
 class ProductsController < ApplicationController
   before_action :set_product, only: %i[ show edit update destroy ]
+  before_action :set_variant, only: %i[ new edit update create ]

   def index
     @products = Product.all
@@ -9,10 +10,12 @@ class ProductsController < ApplicationController
   end

   def new
+    request.variant = @variant
     @product = Product.new
   end

   def edit
+    request.variant = @variant
   end

   def create
@@ -21,7 +24,7 @@ class ProductsController < ApplicationController
     if @product.save
       redirect_to products_path, notice: "Product was successfully created."
     else
-      render :new, status: :unprocessable_entity
+      render :new, variants: @variant, status: :unprocessable_entity
     end
   end

@@ -29,7 +32,7 @@ class ProductsController < ApplicationController
     if @product.update(product_params)
       redirect_to products_path, notice: "Product was successfully updated."
     else
-      render :edit, status: :unprocessable_entity
+      render :edit, variants: @variant, status: :unprocessable_entity
     end
   end

@@ -48,4 +51,8 @@ class ProductsController < ApplicationController
   def product_params
     params.require(:product).permit(:name, :description)
   end
+
+  def set_variant
+    @variant ||= :drawer if params[:variant] == "drawer"
+  end
 end
```

```diff
--- a/app/views/products/index.html.erb
+++ b/app/views/products/index.html.erb
@@ -8,7 +8,7 @@
   <div class="flex justify-between items-center">
     <h1 class="font-bold text-4xl">Products</h1>
     <%= link_to "New product",
-      new_product_path,
+      new_product_path(variant: :drawer),
       class: "rounded-lg py-3 px-5 bg-blue-600 text-white block font-medium" %>
   </div>

```

```diff
--- a/app/views/products/_product.html.erb
+++ b/app/views/products/_product.html.erb
@@ -11,7 +11,7 @@

   <p>
     <%= link_to "Edit this product",
-      edit_product_path(product),
+      edit_product_path(product, variant: :drawer),
       class: "ml-2 rounded-lg py-3 px-5 bg-gray-100 inline-block font-medium" %>
   </p>

```

```diff
--- a/app/views/products/_form.html.erb
+++ b/app/views/products/_form.html.erb
@@ -21,6 +21,8 @@
     <%= form.text_area :description, rows: 4, class: "block shadow rounded-md border border-gray-400 outline-none px-3 py-2 mt-2 w-full" %>
   </div>

+  <%= hidden_field_tag :variant, @variant %>
+
   <div class="inline">
     <%= form.submit class: "rounded-lg py-3 px-5 bg-blue-600 text-white inline-block font-medium cursor-pointer" %>
   </div>
```

Because [Turbo Drive][td] "...updates the page without doing a full reload", the
experience is pretty snappy.

![Navigating to a page that looks like a drawer](https://images.thoughtbot.com/rdtb69f5mbia4csp850lnuyiachi_faux.gif)

[td]: https://turbo.hotwired.dev/handbook/drive
[cr]: https://thoughtbot.com/blog/conditionally-render-turbo-frame
[var]: https://edgeguides.rubyonrails.org/layouts_and_rendering.html#the-variants-option

## Animate the drawer with View Transitions

As snappy as this experience is, a certain level of fidelity is expected when
interacting with drawers.

Fortunately, we can leverage the [View Transition API][vt] to animate the drawer
between page requests.

<aside class="info">
<p>At the time of this writing, the View Transition API is <a href="https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API#browser_compatibility">supported</a>
in all browsers except Firefox.</p>
</aside>

All we need to do is enable the feature by adding a meta tag.

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -3,6 +3,7 @@
   <head>
     <title>HotwireExampleTemplate</title>
     <meta name="viewport" content="width=device-width,initial-scale=1">
+    <meta name="view-transition" content="same-origin" />
     <%= csrf_meta_tags %>
     <%= csp_meta_tag %>
     <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %>
```

From there, we can [customize the animations][ca].

```css
@keyframes fade-out {
  from {
    opacity: 100%;
  }

  to {
    opacity: 0%;
  }
}

@keyframes fade-in {
  from {
    opacity: 0%;
  }

  to {
    opacity: 100%;
  }
}

@keyframes slide-out {
  from {
    transform: translateX(0%);
  }

  to {
    transform: translateX(100%);
  }
}

@keyframes slide-in {
  from {
    transform: translateX(100%);
  }

  to {
    transform: translateX(0%);
  }
}

::view-transition-old(backdrop) {
  animation: 0.4s ease-in both fade-out;
}

::view-transition-new(backdrop) {
  animation: 0.4s ease-in both fade-in;
}

::view-transition-old(panel) {
  animation: 0.4s ease-in both slide-out;
}

::view-transition-new(panel) {
  animation: 0.4s ease-in both slide-in;
}

#panel {
  view-transition-name: panel;
}

#backdrop {
  view-transition-name: backdrop;
}
```

We just need to be sure to identify the relevant drawer elements we want to
animate.

```diff
--- a/app/views/application/_drawer.html.erb
+++ b/app/views/application/_drawer.html.erb
@@ -1,13 +1,15 @@
 <%# locals: (title: )%>

 <div class="relative z-10" aria-labelledby="slide-over-title" role="dialog" aria-modal="true">
-  <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
+  <div id="backdrop"
+       class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
        aria-hidden="true"></div>

   <div class="fixed inset-0 overflow-hidden">
     <div class="absolute inset-0 overflow-hidden">
       <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10">
-        <div class="pointer-events-auto relative w-screen max-w-md">
+        <div id="panel"
+             class="pointer-events-auto relative w-screen max-w-md">
           <div class="absolute left-0 top-0 -ml-8 flex pr-2 pt-4 sm:-ml-10 sm:pr-4">
             <%= link_to :back, class: "relative rounded-md text-gray-300 hover:text-white focus:outline-none focus:ring-2 focus:ring-white" do %>
               <span class="absolute -inset-2.5"></span>
```

With that, our drawer animates in and out. You'll also note that it does not
animate when there's a form error.

![Drawer animating and and out of the page.](https://images.thoughtbot.com/3gmip0jrfavdjezt5l9xn2emeo5b_view_transitions.gif)

[ca]: https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API/Using#customizing_your_animations

## Render the drawer on the current page

At this point, I'd argue that we have a fully functioning drawer component, but
there's still an opportunity to take it a step further by rendering it on the
current page. One way to achieve this is to render the drawer in a [Turbo Frame][tf].

First, we'll need to wrap the existing drawer component in a `turbo_frame_tag`.

```diff
--- a/app/views/application/_drawer.html.erb
+++ b/app/views/application/_drawer.html.erb
@@ -1,5 +1,6 @@
 <%# locals: (title: )%>

+<%= turbo_frame_tag :drawer do %>
   <div class="relative z-10" aria-labelledby="slide-over-title" role="dialog" aria-modal="true">
     <div id="backdrop"
          class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
@@ -33,3 +34,4 @@
       </div>
     </div>
   </div>
+<% end %>
```

Next, we'll want to add the corresponding `turbo_frame_tag` to the relevant
page, and ensure all existing links point to that frame.

```diff
--- a/app/views/products/index.html.erb
+++ b/app/views/products/index.html.erb
@@ -9,7 +9,8 @@
     <h1 class="font-bold text-4xl">Products</h1>
     <%= link_to "New product",
       new_product_path(variant: :drawer),
-      class: "rounded-lg py-3 px-5 bg-blue-600 text-white block font-medium" %>
+      class: "rounded-lg py-3 px-5 bg-blue-600 text-white block font-medium",
+      data: { turbo_frame: :drawer } %>
   </div>

   <div id="products" class="min-w-full">
@@ -18,3 +19,5 @@
     <% end %>
   </div>
 </div>
+
+<%= turbo_frame_tag :drawer %>
```

```diff
--- a/app/views/products/_product.html.erb
+++ b/app/views/products/_product.html.erb
@@ -12,7 +12,8 @@
   <p>
     <%= link_to "Edit this product",
       edit_product_path(product, variant: :drawer),
-      class: "ml-2 rounded-lg py-3 px-5 bg-gray-100 inline-block font-medium" %>
+      class: "ml-2 rounded-lg py-3 px-5 bg-gray-100 inline-block font-medium",
+      data: {turbo_frame: :drawer} %>
   </p>

 </div>
```

Because we're now operating in the context of a Turbo Frame when submitting the
form, we need to refresh the page to ensure the newly created or modified
product appears on the page. This is because requests made from within a Turbo
Frame replace the content of just that frame, not the entire page.

We can do this by conditionally triggering a [page refresh][pr] when the request
is coming from within a Turbo Frame.

```diff
--- a/app/controllers/products_controller.rb
+++ b/app/controllers/products_controller.rb
@@ -22,7 +22,10 @@ class ProductsController < ApplicationController
     @product = Product.new(product_params)

     if @product.save
-      redirect_to products_path, notice: "Product was successfully created."
+      respond_to do |format|
+        format.turbo_stream if turbo_frame_request?
+        format.html { redirect_to products_path, notice: "Product was successfully created." }
+      end
     else
       render :new, variants: @variant, status: :unprocessable_entity
     end
@@ -30,7 +33,10 @@ class ProductsController < ApplicationController

   def update
     if @product.update(product_params)
-      redirect_to products_path, notice: "Product was successfully updated."
+      respond_to do |format|
+        format.turbo_stream if turbo_frame_request?
+        format.html { redirect_to products_path, notice: "Product was successfully updated." }
+      end
     else
       render :edit, variants: @variant, status: :unprocessable_entity
     end
```

```erb
<%# app/views/products/create.turbo_stream.erb %>

<turbo-stream action="refresh"></turbo-stream>
```

```erb
<%# app/views/products/update.turbo_stream.erb %>

<turbo-stream action="refresh"></turbo-stream>
```

If we examine the current behavior, we'll notice that the animations are broken.
The drawer no longer animates in, but does animate out on form submission. It
also no longer animates out when dismissed.

This is because the drawer is now being inserted into the page, rather than being
navigated to. Conversely, dismissing the drawer removes it from the DOM. In each
case, this means the view transitions do not have an opportunity to render.

However, submitting the form still results in a page navigation, which triggers
the view transitions.

![Image of Drawer in a broken state. It does not animate in, nor does it animate out when dismissed](https://images.thoughtbot.com/rnbu4jmgx4goocqp3gwi2yjzmn4w_broken_state.gif)

In order to account for this, we'll need to introduce [el-transition][elt] and
write a custom Stimulus Controller.

We can use [lifecycle callbacks][lc] to animate the drawer in when we detect
that it's entered that page.

On the flip side, we can [pause rendering][pause] so that we can animate those
elements off the page before they're removed from the DOM.

```js
// app/javascript/controllers/drawer_controller.js

import { Controller } from "@hotwired/stimulus";
import { enter, leave } from "el-transition";

// Connects to data-controller="drawer"
export default class extends Controller {
  static targets = ["backdrop", "panel"];

  #isEntering;
  #isLeaving;

  backdropTargetConnected(target) {
    if (this.#isEntering) enter(target);
  }

  panelTargetConnected(target) {
    if (this.#isEntering) enter(target);
  }

  async animate(event) {
    const {
      detail: { newFrame },
    } = event;

    const currentChildCount = this.element.children.length;
    const newChildCount = newFrame.children.length;

    this.#isEntering = currentChildCount == 0 && newChildCount > 0;
    this.#isLeaving = currentChildCount > 0 && newChildCount == 0;

    if (this.#isLeaving) {
      event.preventDefault();

      await Promise.all([
        leave(this.backdropTarget).then(() => this.backdropTarget.remove()),
        leave(this.panelTarget).then(() => this.panelTarget.remove()),
      ]);

      event.detail.resume();
    }
  }
}
```

The key is that we need to inspect the `newFrame` dispatched from
[`turbo:before-frame-render`][event] to determine if the drawer is entering or
leaving.

```js
const {
  detail: { newFrame },
} = event;

const currentChildCount = this.element.children.length;
const newChildCount = newFrame.children.length;
```

Now we need to wire up our controller to our existing Turbo Frame.

```diff
--- a/app/views/products/index.html.erb
+++ b/app/views/products/index.html.erb
@@ -21,4 +21,4 @@
   </div>
 </div>
 
-<%= turbo_frame_tag :drawer %>
+<%= turbo_frame_tag :drawer, data: {controller: "drawer", action: "turbo:before-frame-render->drawer#animate"} %>
```

Finally, we just need to set the [targets][t] and add the expected [dataset
attributes][da].

```diff
--- a/app/views/application/_drawer.html.erb
+++ b/app/views/application/_drawer.html.erb
@@ -4,13 +4,27 @@
   <div class="relative z-10" aria-labelledby="slide-over-title" role="dialog" aria-modal="true">
     <div id="backdrop"
          class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
+         data-drawer-target="backdrop"
+         data-transition-enter="ease-in-out duration-500"
+         data-transition-enter-start="opacity-0"
+         data-transition-enter-end="opacity-100"
+         data-transition-leave="ease-in-out duration-500"
+         data-transition-leave-start="opacity-100"
+         data-transition-leave-end="opacity-0"
          aria-hidden="true"></div>
 
     <div class="fixed inset-0 overflow-hidden">
       <div class="absolute inset-0 overflow-hidden">
         <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10">
           <div id="panel"
-               class="pointer-events-auto relative w-screen max-w-md">
+               class="pointer-events-auto relative w-screen max-w-md"
+               data-transition-enter="transform transition ease-in-out duration-500 sm:duration-700"
+               data-transition-enter-start="translate-x-full"
+               data-transition-enter-end="translate-x-0"
+               data-transition-leave="transform transition ease-in-out duration-500 sm:duration-700"
+               data-transition-leave-start="translate-x-0"
+               data-transition-leave-end="translate-x-full"
+               data-drawer-target="panel">
             <div class="absolute left-0 top-0 -ml-8 flex pr-2 pt-4 sm:-ml-10 sm:pr-4">
               <%= link_to :back, class: "relative rounded-md text-gray-300 hover:text-white focus:outline-none focus:ring-2 focus:ring-white" do %>
                 <span class="absolute -inset-2.5"></span>
```

And with that, our drawer now animates in and out of the current page.

![Image of drawer component animating in and out](https://images.thoughtbot.com/x4i3prq8abqoxaxfubhvgs0ogxnq_final.gif)

[tf]: https://turbo.hotwired.dev/handbook/frames
[pr]: https://turbo.hotwired.dev/reference/streams#refresh
[lc]: https://stimulus.hotwired.dev/reference/lifecycle-callbacks
[pause]: https://turbo.hotwired.dev/handbook/frames#pausing-rendering 
[elt]: https://github.com/mmccall10/el-transition
[event]: https://turbo.hotwired.dev/reference/events#turbo%3Abefore-frame-render
[t]: https://stimulus.hotwired.dev/reference/targets
[da]: https://github.com/mmccall10/el-transition?tab=readme-ov-file#dataset-attributes

## Wrapping up

I hope this tutorial highlighted the power of server-side rendering coupled with
emerging web APIs. By simply creating a page that _looks_ like a drawer and
using the [View Transition API][vt], we were able to create a fully functioning
drawer component without using any JavaScript. I hope you found it as compelling
as I did.

[vt]: https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API
