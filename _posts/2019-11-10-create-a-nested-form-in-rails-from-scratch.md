---
title: Create a Nested Form in Rails from Scratch
categories: ["Ruby on Rails"]
resources: [
    {
        title: "Repo",
        url: "https://github.com/stevepolitodesign/rails-nested-form-example"
    },
    {
        title: "Building Complex Forms in Rails",
        url: "https://guides.rubyonrails.org/form_helpers.html#building-complex-forms"
    },    
    {
        title: "cocoon",
        url: "https://github.com/nathanvda/cocoon"
    },
    {
        title: "Rails Casts",
        url: "http://railscasts.com/episodes/196-nested-model-form-revised"
    }
]
date: 2019-11-10
---

The [Rails Guides](https://guides.rubyonrails.org/form_helpers.html#building-complex-forms) give a great example of how to create nested forms. However, Rails does not support [adding fields on the fly](https://guides.rubyonrails.org/form_helpers.html#adding-fields-on-the-fly) out of the box. The [cocoon Gem](https://github.com/nathanvda/cocoon) is one alternative, as is [Ryan Bates' excellent tutorial](http://railscasts.com/episodes/196-nested-model-form-revised). However, both require jQuery which does not ship with Rails 6.

In this tutorial, I'll show you how you can create a nested form in Rails from scratch.

{% youtube "https://www.youtube.com/embed/K45V1JOrP8o" %}

## 1. Configuring the Model

```ruby
class Person < ApplicationRecord
    has_many :addresses, inverse_of: :person
    accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: :all_blank
end
```

## 2. Declare the Permitted Parameters

```ruby
class PeopleController < ApplicationController
    ...
    private

        def person_params
            params.require(:person).permit(:first_name, :last_name, addresses_attributes: [:id, :kind, :street, :_destroy])
        end
end
```

## 3. Create a Form Partial

```erb
<%# app/views/people/_address_fields.html.erb %>
<div class="nested-fields">
    <%= f.hidden_field :_destroy %>
    <div>
        <%= f.label :kind %>
        <%= f.text_field :kind %>
    </div>
    <div>
        <%= f.label :street %>
        <%= f.text_field :street %>
    </div>
    <div>
        <%= link_to "Remove", '#', class: "remove_fields" %>
    </div>
</div>
```

```erb{6-9}
<%# app/views/people/_form.html.erb %>
<%= form_with model: @person, local: true do |f| %>
    ...
    <fieldset>
        <legend>Addresses:</legend>
        <%= f.fields_for :addresses do |addresses_form| %>
            <%= render "address_fields", f: addresses_form %>
        <% end %>
        <%= link_to_add_fields "Add Addresses", f, :addresses %>
    </fieldset>

    <%= f.submit %>
<% end %>
```

## 4. Create a Helper Function

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper

    # This method creates a link with `data-id` `data-fields` attributes. These attributes are used to create new instances of the nested fields through Javascript.
    def link_to_add_fields(name, f, association)

        # Takes an object (@person) and creates a new instance of its associated model (:addresses)
        # To better understand, run the following in your terminal:
        # rails c --sandbox
        # @person = Person.new
        # new_object = @person.send(:addresses).klass.new
        new_object = f.object.send(association).klass.new

        # Saves the unique ID of the object into a variable.
        # This is needed to ensure the key of the associated array is unique. This is makes parsing the content in the `data-fields` attribute easier through Javascript.
        # We could use another method to achive this.
        id = new_object.object_id

        # https://api.rubyonrails.org/ fields_for(record_name, record_object = nil, fields_options = {}, &block)
        # record_name = :addresses
        # record_object = new_object
        # fields_options = { child_index: id }
            # child_index` is used to ensure the key of the associated array is unique, and that it matched the value in the `data-id` attribute.
            # `person[addresses_attributes][child_index_value][_destroy]`
        fields = f.fields_for(association, new_object, child_index: id) do |builder|

            # `association.to_s.singularize + "_fields"` ends up evaluating to `address_fields`
            # The render function will then look for `views/people/_address_fields.html.erb`
            # The render function also needs to be passed the value of 'builder', because `views/people/_address_fields.html.erb` needs this to render the form tags.
            render(association.to_s.singularize + "_fields", f: builder)
        end

        # This renders a simple link, but passes information into `data` attributes.
            # This info can be named anything we want, but in this case we chose `data-id:` and `data-fields:`.
        # The `id:` is from `new_object.object_id`.
        # The `fields:` are rendered from the `fields` blocks.
            # We use `gsub("\n", "")` to remove anywhite space from the rendered partial.
        # The `id:` value needs to match the value used in `child_index: id`.
        link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})

    end
end
```

## 5. Add Javascript

```javascript
// app/javascript/packs/nested-forms/addFields.js
class addFields {
  // This executes when the function is instantiated.
  constructor() {
    this.links = document.querySelectorAll('.add_fields')
    this.iterateLinks()
  }

  iterateLinks() {
    // If there are no links on the page, stop the function from executing.
    if (this.links.length === 0) return
    // Loop over each link on the page. A page could have multiple nested forms.
    this.links.forEach(link => {
      link.addEventListener('click', e => {
        this.handleClick(link, e)
      })
    })
  }

  handleClick(link, e) {
    // Stop the function from executing if a link or event were not passed into the function.
    if (!link || !e) return
    // Prevent the browser from following the URL.
    e.preventDefault()
    // Save a unique timestamp to ensure the key of the associated array is unique.
    let time = new Date().getTime()
    // Save the data id attribute into a variable. This corresponds to `new_object.object_id`.
    let linkId = link.dataset.id
    // Create a new regular expression needed to find any instance of the `new_object.object_id` used in the fields data attribute if there's a value in `linkId`.
    let regexp = linkId ? new RegExp(linkId, 'g') : null
    // Replace all instances of the `new_object.object_id` with `time`, and save markup into a variable if there's a value in `regexp`.
    let newFields = regexp ? link.dataset.fields.replace(regexp, time) : null
    // Add the new markup to the form if there are fields to add.
    newFields ? link.insertAdjacentHTML('beforebegin', newFields) : null
  }
}

// Wait for turbolinks to load, otherwise `document.querySelectorAll()` won't work
window.addEventListener('turbolinks:load', () => new addFields())
```

```javascript
// app/javascript/packs/nested-forms/removeFields.js
class removeFields {
  // This executes when the function is instantiated.
  constructor() {
    this.iterateLinks()
  }

  iterateLinks() {
    // Use event delegation to ensure any fields added after the page loads are captured.
    document.addEventListener('click', e => {
      if (e.target && e.target.className == 'remove_fields') {
        this.handleClick(e.target, e)
      }
    })
  }

  handleClick(link, e) {
    // Stop the function from executing if a link or event were not passed into the function.
    if (!link || !e) return
    // Prevent the browser from following the URL.
    e.preventDefault()
    // Find the parent wrapper for the set of nested fields.
    let fieldParent = link.closest('.nested-fields')
    // If there is a parent wrapper, find the hidden delete field.
    let deleteField = fieldParent
      ? fieldParent.querySelector('input[type="hidden"]')
      : null
    // If there is a delete field, update the value to `1` and hide the corresponding nested fields.
    if (deleteField) {
      deleteField.value = 1
      fieldParent.style.display = 'none'
    }
  }
}

// Wait for turbolinks to load, otherwise `document.querySelectorAll()` won't work
window.addEventListener('turbolinks:load', () => new removeFields())
```

```javascript
// app/javascript/packs/application.js
require('./nested-forms/addFields')
require('./nested-forms/removeFields')
```
