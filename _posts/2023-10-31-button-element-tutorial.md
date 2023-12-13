---
title: Are you absolutely sure you know how to use the button element?
excerpts: Read this the next time you need to build a complicated form.
categories: ["Ruby on Rails"]
canonical_url: https://thoughtbot.com/blog/button-element-tutorial
---

I used to think the `<button>` element could only exist inside a `<form>` and
that it did not support any attributes. In other words, I basically thought it
was a more semantic version of `<input type="submit">`.

However, after working on a payment form for a client project, I realized that
the `<button>` element is a robust, versatile and under utilized tool. Plus,
knowing how to leverage forms and buttons will benefit you when using [Turbo][]
and [Stimulus][].

[Turbo]: https://thoughtbot.com/blog/dynamic-forms-with-turbo
[Stimulus]: https://thoughtbot.com/blog/dynamic-forms-with-stimulus

## Our base

Here's a traditional Rails form that we'll be working with in this tutorial.
It's nothing special, and the only thing we need to focus on for now is the fact
that the [`form.button`][] is located within the form per usual. That's about to
change.

```erb
<%= form_with model: payment,
      class: "contents" do |form| %>

  <div>
    <%= form.label :amount %>
    <%= form.number_field :amount, required: true %>
  </div>

  <div>
    <%= form.label :payment_method %>
    <%= form.collection_radio_buttons :payment_method_id,
          PaymentMethod.all,
          :id,
          :display_name do |builder| %>
      <div>
        <%= builder.label do %>
          <%= builder.radio_button required: true %>
          <%= builder.text %>
        <% end %>
      </div>
    <% end %>
  </div>

  <div>
    <%= form.button "Pay Now" %>
  </div>
<% end %>
```

[`form.button`]: https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-button

## A simple example

Imagine our designer wants the "Pay Now" button to be fixed to the bottom of the
screen in an effort to make it stand out. In order to do this, we'll need to
actually place the button **outside** of the form.

![An image of a payment form. The "Pay Now" button is fixed to the bottom of the
screen.](https://images.thoughtbot.com/ghmz9c6znve20v7uhmbozqx39enw_button_outside.png)

You might be thinking the only way we can still submit the form with the same
button is to use JavaScript, but you'd be wrong. The solution is quite simple.

All we need to do is leverage the [form][] attribute.

> The value of this attribute must be the id of a `<form>` in the same document.
> (If this attribute is not set, the `<button>` is associated with its ancestor
> `<form>` element, if any.)

```diff
--- a/app/views/payments/_form.html.erb
+++ b/app/views/payments/_form.html.erb
@@ -1,4 +1,5 @@
 <%= form_with model: payment,
+      id: dom_id(payment),
       class: "contents" do |form| %>
-
-  <div>
-    <%= form.button "Pay Now" %>
-  </div>
 <% end %>
```

```diff
--- a/app/views/payments/new.html.erb
+++ b/app/views/payments/new.html.erb
@@ -5,3 +5,8 @@

   <%= link_to "Back to payments", payments_path %>
 </div>
+
+<%= button_tag "Pay Now", form: dom_id(@payment) %>
```

In order to ensure we map to the correct `id`, we utilize the [dom_id][] method
on both the form and button. However, we could have just hard-coded an `id` if
we wanted to.

Additionally, we can confirm that hitting the <kbd>Return</kbd> key when an
element in the form is focused will still submit the form, even though it no
longer contains a submit button.

![A demo of submitting the form via keyboard navigation. Hitting the "Return"
key submits the
form.](https://images.thoughtbot.com/cfw0tv5cr4vkvlbg8bp8ohvam5av_return_key.gif)

[form]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#form
[dom_id]: https://api.rubyonrails.org/classes/ActionView/RecordIdentifier.html#method-i-dom_id

## A complex example

Now imagine our designer comes back with a request that would allow a user to
delete payment methods on the same form.

Here are a few ways we could achieve this:

- Use the [link_to][] method with `data: { turbo_method: :delete }`.
- Add hidden fields to the form and set their values to the IDs of the payment
  methods that should be deleted.

Although these are both acceptable solutions, there's a more semantic
alternative. Instead, we can easily accomplish this task by leveraging more
button attributes.

[link_to]: https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to-label-Turbo

```diff
--- a/app/views/payments/_form.html.erb
+++ b/app/views/payments/_form.html.erb
@@ -26,6 +26,12 @@
           <%= builder.radio_button required: true %>
           <%= builder.text %>
         <% end %>
+        <%= form.button "Delete #{builder.object.display_name}",
+              formaction: payment_method_path(builder.object),
+              name: "_method",
+              value: "delete",
+              formnovalidate: true,
+              data: {turbo_confirm: "Delete #{builder.object.display_name}?"} %>
       </div>
     <% end %>
   </div>
```

So, what's going on here? The [formaction][] attribute simply overrides the
parent form's `action`. There's no need to set a [formmethod][] attribute because
the parent form's `method` is already set to `"post"`.

The [name][] and [value][] attributes are passed as form data to the
controller. We do this to [ensure we can make a DELETE request][]. Here's what
the request looks like:

[formaction]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#formaction
[name]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#name
[value]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#value
[ensure we can make a DELETE request]: https://guides.rubyonrails.org/form_helpers.html#how-do-forms-with-patch-put-or-delete-methods-work-questionmark

```ruby
{
  "authenticity_token"=>"123abc",
  "payment"=>{"amount"=>"100", "payment_method_id"=>"1"},
  "_method"=>"delete", #<- "name" => "value"
  "action"=>"destroy",
  "id"=>"1"
  "controller"=>"payment_methods",
}
```

You can almost think of this button as a form similar to the following:

```html
<form action="/payment_methods/1" method="post">
  <input type="hidden" name="_method" value="delete" />
  <button>Delete Payment Method</button>
</form>
```

However, we can further simplify this implementation by leveraging the
[formmethod][] attribute. Although this attribute normally only supports `post`,
`get`, and `dialog`, the `form.button` is able to support `delete` just like
[Rails' forms][].

```diff
--- a/app/views/payments/_form.html.erb
+++ b/app/views/payments/_form.html.erb
@@ -28,8 +28,7 @@
         <% end %>
         <%= form.button "Delete #{builder.object.display_name}",
               formaction: payment_method_path(builder.object),
-              name: "_method",
-              value: "delete",
+              formmethod: :delete,
               formnovalidate: true,
               data: { turbo_confirm: "Delete #{builder.object.display_name}?" },
```

[Rails' forms]: https://guides.rubyonrails.org/form_helpers.html#how-do-forms-with-patch-put-or-delete-methods-work-questionmark

You might be wondering why we set the [formnovalidate][] attribute. We can
demonstrate what it does by temporarily having it removed. You won't be able to
delete a payment method if the rest of the form is invalid.

[formnovalidate]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#formnovalidate
[formmethod]: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/button#formmethod

![An image of an invalid form. Hitting a button to delete a payment does not
work, and instead validates the payment form. The "Amount" field has an error
reading: Please fill out this
field.](https://images.thoughtbot.com/k43p4qfsykp5l84bjyll3xmhmp8j_formnovalidate.png)

There is one subtle issue with the current state of our form, but it's a big
one: Hitting the <kbd>Return</kbd> key does not submit the form. Instead, it
triggers one of the delete payment method buttons.

![A video of the form being navigated with a keyboard. Hitting the Return key
unexpectedly triggers the delete payment method
button](https://images.thoughtbot.com/48dw4c8jk8b1jd2zcixjg4yvgaec_unexpected_submit.gif)

This is because hitting the <kbd>Return</kbd> key will use the first submit
button in the form. In this case, that happens to be a button to delete a
payment method. To fix this, we can simply add back the submit button, this time
at the **top** of the form. Since we don't want two "Pay Now" buttons, we can
simply make it [hidden][].

```diff
--- a/app/views/payments/_form.html.erb
+++ b/app/views/payments/_form.html.erb
@@ -13,6 +13,8 @@

+  <%= form.button "Pay Now", hidden: true %>
+
   <div>
     <%= form.label :amount %>
     <%= form.number_field :amount, required: true %>
```

In other words, we are making this button inaccessible by design by removing its
semantics from the document.

[hidden]: https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/hidden
[tabindex]: https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/tabindex
