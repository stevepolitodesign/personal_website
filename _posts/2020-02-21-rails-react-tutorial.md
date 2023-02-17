---
title: "Ruby on Rails with React Tutorial"
excerpt:
  Many Rails+React tutorials demonstrate how to create an API only application
  using Rails, and then create a separate front-end application to digest the API
  with React. Other React tutorials have you work with something like Firebase to
  handle the back-end of the application.

  Although both of these approaches are common and acceptable, I wanted to create
  an application that has all the benefits of a non API only Rails application,
  without the limitations and vendor lock-in of a third party service like
  Firebase.
categories: ["Ruby on Rails", "Web Development"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/rails-react-example",
    },
    { title: "Demo", url: "https://rails-react-example.herokuapp.com/" },
  ]
date: 2020-02-21
---

## Introduction

Many Rails+React tutorials demonstrate how to create an [API only application](https://guides.rubyonrails.org/api_app.html) using Rails, and then create a separate front-end application to digest the API with React. Other React tutorials have you work with something like [Firebase](https://firebase.google.com/) to handle the back-end of the application.

Although both of these approaches are common and acceptable, I wanted to create an application that has all the benefits of a non API only Rails application, without the limitations and vendor lock-in of a third party service like Firebase.

For this application we are going to build both the front-end and back-end within a single Rails application. However, we're only going to load React on a specific part of a specific `view`.

![application demo](/assets/images/posts/rails-react-tutorial/demo.gif)

Some of the advantages for building both the front-end and back-end within a single Rails application are as follows:

- We can build out other pages using `.erb` files. Not everything needs to be in React. Imagine if we want to add a contact us page, or an about page in the future? It would be cumbersome to need to build these pages in React.
- We can easily and quickly build an authentication system using [Devise](https://github.com/heartcombo/devise). This will handle authentication across the entire application, and will make handling requests in our API a lot easier.
- Rails already does a great job of making an application feel like a single page application with [Turbolinks](https://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbolinks). For example, this will make logging in an out of the application feel like it's built in React.
- Rails handles tricky [security considerations](https://guides.rubyonrails.org/security.html) that are easily overlooked when building an API.
- Rails makes [validating our models](https://guides.rubyonrails.org/active_record_validations.html) incredibly easy.

## Considerations

We will be deviating from a traditional Rails application by replacing a specific `view` with a React application. This means that we will no longer be able to use some of the features we take for granted in a Rails application, like [form helpers](https://guides.rubyonrails.org/form_helpers.html) or [flash notices](https://api.rubyonrails.org/classes/ActionDispatch/Flash.html). Below are some often overlooked features that we will be responsible for.

- API authorization
- API versioning
- Setting HTTP status codes
- Form validation on the front-end
- Handling errors
- Debouncing requests
- CSRF Countermeasures

## Step 1: Create a New Rails Application

In a new terminal window, run the following commands.

```sh
rails new todo-application -d=postgresql --webpacker=react
cd todo-application
rails db:create
rails s
```

Notes:

- We append `--webpacker=react` to the `rails new` command in order to install React and its dependencies. This command also generates a sample React component at `app/javascript/packs/hello_react.jsx`, and creates a file to manage Webpack at `config/webpacker.yml`.
- We append `-d=postgresql` to the `rails new` command in order to use PostgreSQL as the default database. This is personal preference, but something I recommend since it makes deploying to [Heroku](https://www.heroku.com/) easier.

If you open up a browser and navigate to [http://localhost:3000/](http://localhost:3000/) you should see the following:

![Rails intro page](/assets/images/posts/rails-react-tutorial/1.0.png)

### Create Homepage

In a new terminal window run the following command.

```sh
rails g controller pages home my_todo_items
```

This command generates and modifies a lot of files, but all we will care about are `app/views/pages/` and `app/controllers/pages_controller.rb`.

Open up `config/routes.rb` and replace `get 'pages/home'` with `root 'pages#home'`

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root "pages#home"
  get "pages/my_todo_items"
end
```

If you open up a browser and navigate to [http://localhost:3000/](http://localhost:3000/) you should see the following:

![homepage](/assets/images/posts/rails-react-tutorial/1.1.png)

### Load Bootstrap

In the interest of time, we're going to use [Bootstrap](https://getbootstrap.com/) to style our application. Luckily Bootstrap can be installed as a dependency, which means we can use it for our React application, as well as regular Rails `.erb` files.

In a new terminal window run the following command.

```sh
yarn add bootstrap jquery popper.js
```

Open `app/javascript/packs/application.js` add the following.

<pre data-line="18-19">
  <code class="language-javascript">
    // This file is automatically compiled by Webpack, along with any other files
    // present in this directory. You're encouraged to place your actual application logic in
    // a relevant structure within app/javascript and only use these pack files to reference
    // that code so it'll be compiled.
    
    require("@rails/ujs").start();
    require("turbolinks").start();
    require("@rails/activestorage").start();
    require("channels");
    
    // Uncomment to copy all static images under ../images to the output folder and reference
    // them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
    // or the `imagePath` JavaScript helper below.
    //
    // const images = require.context('../images', true)
    // const imagePath = (name) => images(name, true)
    require("bootstrap");
    import "bootstrap/dist/css/bootstrap";
  </code>
</pre>

Open `app/views/layouts/application.html.erb` and add `<%= stylesheet_pack_tag 'application' %>`.

```erb
<pre>
  <code class="language-erb">
    <!DOCTYPE html>
    <html>
      <head>
        <title>TodoApplication</title>
        <%= csrf_meta_tags %>
        <%= csp_meta_tag %>

        <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
        <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>

        <%# ℹ️ Add this line %>
        <%= stylesheet_pack_tag 'application' %>

      </head>

      <body>
        <%= yield %>
      </body>
    </html>
  </code>
</pre>
```

If you open up a browser and navigate to [http://localhost:3000/](http://localhost:3000/) you should notice that Bootstrap is now affecting site styes.

![homepage](/assets/images/posts/rails-react-tutorial/1.2.png)

### Load Sample React Application

Finally, we want to ensure that both React and webpacker are working properly. To do so, we will temporarily load the sample React application that shipped with our Rails application. Open up `app/javascript/packs/application.js` and add `require("./hello_react");`

<pre data-line="18">
  <code class="language-javascript">
    // This file is automatically compiled by Webpack, along with any other files
    // present in this directory. You're encouraged to place your actual application logic in
    // a relevant structure within app/javascript and only use these pack files to reference
    // that code so it'll be compiled.
    
    require("@rails/ujs").start();
    require("turbolinks").start();
    require("@rails/activestorage").start();
    require("channels");
    
    // Uncomment to copy all static images under ../images to the output folder and reference
    // them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
    // or the `imagePath` JavaScript helper below.
    //
    // const images = require.context('../images', true)
    // const imagePath = (name) => images(name, true)
    require("./hello_react");
    require("bootstrap");
    import "bootstrap/dist/css/bootstrap";
  </code>
</pre>

If you open up a browser and navigate to [http://localhost:3000/](http://localhost:3000/) you should notice that the sample React application has loaded, and is displaying `Hello React!`.

![sample React application has loaded](/assets/images/posts/rails-react-tutorial/1.3.png)

## Step 2: Install and Configure Devise

In order for someone to use our application, they'll need to create an account. Instead of building an authentication system from scratch, we'll use [devise](https://github.com/heartcombo/devise). Devise is a battle tested, well documented authentication solution for Rails.

1. Open up your `Gemfile` and add `gem 'devise', '~> 4.7', '>= 4.7.1'`.
2. In a terminal window run `bundle install`.
3. Then run `rails generate devise:install`.
4. Open `config/environments/development.rb` and add `config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }`.

```ruby
Rails.application.configure do
  # config/environments/development.rb

  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
end
```

### Generate a User Model

Now we need to generate a `User` model. This model will eventually be associated with the `TodoItem` model.

1. In a terminal window run `rails generate devise User`.
2. Then run `rails db:migrate`
3. Open up `db/seeds.rb` and add the following.

   ```ruby
   # db/seeds.rb

   2.times do |i|
     User.create(
       email: "user-#{i + 1}@example.com",
       password: "password",
       password_confirmation: "password",
     )
   end
   ```

4. Finally in a terminal window run `rails db:seed`

### Build a Header

Now we need a way for users to login and out of our application. Don't get too bogged down on these steps, since they have less to do with React, and more to do with styling.

1. In a terminal window run `mkdir app/views/shared`.
2. Then run `touch app/views/shared/_flash.html.erb`.
3. Then run `touch app/views/shared/_navigation.html.erb`.
4. Open up `app/views/shared/_flash.html.erb` and add the following.

   ```erb
   # app/views/shared/_flash.html.erb
   <% flash.each do |key, value| %>
     <div class="container">
       <div class="alert <%= key == 'notice' ? 'alert-primary' : 'alert-danger' %>" role="alert">
         <%= value %>
         <button type="button" class="close" data-dismiss="alert" aria-label="Close">
           <span aria-hidden="true">&times;</span>
         </button>
       </div>
     </div>
   <% end %>
   ```

5. Open up `app/views/shared/_navigation.html.erb` and add the following.

   ```erb
   <!-- app/views/shared/_navigation.html.erb -->
   <nav class="navbar navbar-expand-lg navbar-light bg-light mb-5">
     <div class="container">
       <%= link_to "Rails React Example", root_path, class: "navbar-brand" %>
       <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
         <span class="navbar-toggler-icon"></span>
       </button>
       <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
         <ul class="navbar-nav">
           <li class="nav-item">
             <% if user_signed_in? %>
               <%= link_to('Logout', destroy_user_session_path, method: :delete, class: "nav-link") %>
             <% else %>
               <%= link_to('Login', new_user_session_path, class: "nav-link") %>
             <% end %>
           </li>
         </ul>
       </div>
     </div>
   </nav>
   ```

   The only part that really matters here is the following:

   ```erb
   <% if user_signed_in? %>
     <%= link_to('Logout', destroy_user_session_path, method: :delete, class: "nav-link") %>
   <% else %>
     <%= link_to('Login', new_user_session_path, class: "nav-link") %>
   <% end %>
   ```

   This conditional toggles a Log In link or a Log Out link.

6. Load these partials into `app/views/layouts/application.html.erb`.

   ```erb
   <!-- app/views/layouts/application.html.erb -->
   <!DOCTYPE html>
   <html>
     <head>
       <title>TodoApplication</title>
       <%= csrf_meta_tags %>
       <%= csp_meta_tag %>

       <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
       <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
       <%= stylesheet_pack_tag 'application' %>

     </head>

     <body>
       <%# ℹ️ Load these partials %>
       <%= render "shared/navigation" %>
       <%= render "shared/flash" %>
       <%= yield %>
     </body>
   </html>
   ```

7. As a final step, let's add a [container](https://getbootstrap.com/docs/4.4/layout/overview/#containers) to the page, as well as [responsive meta tag](https://getbootstrap.com/docs/4.4/getting-started/introduction/#responsive-meta-tag).

   ```erb
   <!-- app/views/layouts/application.html.erb -->
   <!DOCTYPE html>
   <html>
     <head>
       <title>TodoApplication</title>
       <%= csrf_meta_tags %>
       <%= csp_meta_tag %>

       <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
       <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
       <%= stylesheet_pack_tag 'application' %>

       <%# ℹ️ Add meta-tag %>
       <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

     </head>

     <body>
       <%= render "shared/navigation" %>
       <%= render "shared/flash" %>

       <%# ℹ️ Add container %>
       <div class="container">
         <%= yield %>
       </div>
     </body>
   </html>
   ```

   If you open up a browser and navigate to [http://localhost:3000/](http://localhost:3000/) you should see the following.

   ![newly added header](/assets/images/posts/rails-react-tutorial/2.0.png)

### Create Homepage for Authorized Users

Now that we have a way to login and out of our application, let's add a homepage that only authentication users will see. This page will eventually display our React application.

1. Open up `config/routes.rb` and add the following:

<pre data-line="6-8">
  <code class="language-ruby">
    # config/routes.rb
    
    Rails.application.routes.draw do
      devise_for :users
      authenticated :user do
        root "pages#my_todo_items", as: :authenticated_root
      end
      root "pages#home"
    end
  </code>
</pre>

You can read more about this in the [devise documentation](https://github.com/heartcombo/devise/wiki/How-To:-Define-a-different-root-route-for-logged-out-users).

### Style Login Page (Optional)

Right now our application's login page is not styled as seen below.

![un styled login page](/assets/images/posts/rails-react-tutorial/2.1.png)

Luckily devise gives us the option to [style these views](https://github.com/heartcombo/devise#configuring-views).

1. In a terminal window run `rails generate devise:views`.
1. Open up `app/views/devise/sessions/new.html.erb` and add the following.

   - Note that I am simply adjusting the markup, and not affecting functionality. This is strictly a cosmetic edit.

   ```erb
   <!-- app/views/devise/sessions/new.html.erb -->
   <h2>Log in</h2>
   <div class="row">
     <div class="col-md-6 col-lg-8">
       <h4>User the following accounts to test the application</h4>
       <table class="table table-sm">
         <thead>
           <tr>
             <th scope="col">Email</th>
             <th scope="col">Password</th>
           </tr>
         </thead>
         <tbody>
           <% User.all.each do |user| %>
             <tr>
               <td><%= user.email %></td>
               <td>password</td>
             </tr>
           <% end %>
         </tbody>
       </table>
     </div>
     <div class="col-md-6 col-lg-4">
       <%= form_for(resource, as: resource_name, url: session_path(resource_name), html: { class: "border shadow-sm rounded p-3 mb-3" } ) do |f| %>
         <div class="form-group">
           <%= f.label :email %>
           <%= f.email_field :email, autofocus: true, autocomplete: "email", class: "form-control" %>
         </div>

         <div class="form-group">
           <%= f.label :password %><br />
           <%= f.password_field :password, autocomplete: "current-password", class: "form-control" %>
         </div>

         <% if devise_mapping.rememberable? %>
           <div class="form-group">
             <%= f.check_box :remember_me %>
             <%= f.label :remember_me %>
           </div>
         <% end %>

         <div class="form-group">
           <%= f.submit "Log in", class: "btn btn-primary" %>
         </div>
       <% end %>

       <%= render "devise/shared/links" %>

     </div>
   </div>
   ```

   If you open up a browser and navigate to [http://localhost:3000/users/sign_in](http://localhost:3000/users/sign_in) you should see the following.

   ![styled login page](/assets/images/posts/rails-react-tutorial/2.2.png)

## Step 3: Create Todo Item Model

Now we need to create a model to that will represent our todo items, and have them associated with our `User` model.

1. In a terminal window run `rails g model TodoItem title user:references complete:boolean`.

   What we're doing here is creating a new model named `TodoItem`. It will have a `title` field, a `complete` field that is simply a boolean, and finally it will be associated with our `User` model.

2. Open up the newly created migration file `db/migrate/YYYYMMDDHHMMSS_create_todo_items.rb` and add the following.

   <pre data-line="9">
     <code class="language-ruby">
       # db/migrate/YYYYMMDDHHMMSS_create_todo_items.rb
       
       class CreateTodoItems < ActiveRecord::Migration[6.0]
         def change
           create_table :todo_items do |t|
             t.string :title
             t.references :user, null: false, foreign_key: true
             t.boolean :complete, default: false
       
             t.timestamps
           end
         end
       end
     </code>
   </pre>

   By adding `default: false`, we're telling the database that the default value for `complete` on a `TodoItem` will be `false`.

3. In a terminal window run `rails db:migrate`

### Write Validations

Now that we have a `TodoItem` model, we should write some validations to ensure any data saved into the database is valid. For example, we don't want a `TodoItem` to be saved if there's no `title`, or if it's not associated with a `User`.

1. Open up `app/models/todo_item.rb` and add the following.

   ```ruby
   # app/models/todo_item.rb

   class TodoItem < ApplicationRecord
     belongs_to :user

     validates :title, presence: true
   end
   ```

### Set a Default Scope

Next we'll want to ensure that the newest `TodoItems` appear first when queried. To do this, we can use a [default scope](https://guides.rubyonrails.org/active_record_querying.html#applying-a-default-scope).

1. Open up `app/models/todo_item.rb` and add the following.

<pre data-line="5">
  <code class="language-ruby">
    # app/models/todo_item.rb
    
    class TodoItem < ApplicationRecord
      default_scope { order(created_at: :desc) }
    
      belongs_to :user
    
      validates :title, presence: true
    end
  </code>
</pre>

### Create Association Between User and TodoItem

Next we need to create an association between the `User` and the `TodoItem`. This has already been started for us in `app/models/todo_item.rb` with the `belongs_to :user` line.

1. Open up `app/models/user.rb` and add the following.

   ```ruby
   # app/models/user.rb

   class User < ApplicationRecord
     has_many :todo_items, dependent: :destroy
   end
   ```

   This ensures that a `User` is associated with many `TodoItems`. It also means that if a `User` is deleted, so will their associated `ToDoItems`.

### Add Seed Data

Finally, let's add some sample data.

1. Open up `db/seeds.rb` and add the following.

   <pre data-line="10-17">
     <code class="language-ruby">
       # db/seeds.rb
       2.times do |i|
         User.create(
           email: "user-#{i + 1}@example.com",
           password: "password",
           password_confirmation: "password",
         )
       end
       
       User.all.each do |u|
         10.times do |i|
           u.todo_items.create(
             title: "To Do Item #{i + 1} for #{u.email}",
             complete: i % 3 == 0 ? true : false,
           )
         end
       end
     </code>
   </pre>

   This simply creates 10 `TodoItems` for each `User`, and marks every third item `complete`.

2. In a terminal window run `rails db:seed`.
3. To ensure everything worked, open up a terminal widow and run `rails c`. Once the environment loads, run `TodoItem.count`. The output should be similar to the following:

   ```sh
   2.6.3 :001 > TodoItem.count
   (14.8ms) SELECT COUNT(\*) FROM "todo_items"
   => 20
   ```

## Set 4: Create the API

Now that we have our data models, we need to create an API for our React application to digest.

### Generate a Controller

1. In a new terminal window run `rails g controller api/v1/todo_items`.

We pass the command `api/v1/todo_items` and not `todo_items` because we want to [namespace](https://guides.rubyonrails.org/routing.html#controller-namespaces-and-routing) our API. This is not required, but is encouraged. In the future, other applications could digest our API. If at anytime we were to change our API, we would risk breaking these applications. It's best to version our API so that other applications can opt-in to new features.

### Create Non Authorized End Points

#### Create Empty Controller Actions

First we need to create an action for each endpoint in our API.

1. Open up `app/controllers/api/v1/todo_items_controller.rb` and add the following.

   ```ruby
   # app/controllers/api/v1/todo_items_controller.rb

   class Api::V1::TodoItemsController < ApplicationController
     before_action :set_todo_item, only: %i[show edit update destroy]

     def index
     end

     def show
     end

     def create
     end

     def update
     end

     def destroy
     end

     private

     def set_todo_item
       @todo_item = TodoItem.find(params[:id])
     end
   end
   ```

The private `set_todo_item` method will [find](https://guides.rubyonrails.org/routing.html#connecting-urls-to-code) the `TodoItem` based on the `ID` in the URL.

#### Update Routes

Now we need to create corresponding routes for our controller actions.

1. Open up `config/routes.rb` and add the following.

<pre data-line="10-14">
  <code class="language-ruby">
    # config/routes.rb
    
    Rails.application.routes.draw do
      devise_for :users
      authenticated :user do
        root "pages#my_todo_items", as: :authenticated_root
      end
      root "pages#home"
      namespace :api, defaults: { format: :json } do
        namespace :v1 do
          resources :todo_items, only: %i[index show create update destroy]
        end
      end
    end
  </code>
</pre>

We use a [namespace](https://guides.rubyonrails.org/routing.html#controller-namespaces-and-routing) in order to make our routes render at `/api/v1/todo_items`. This way, we can easily add new versions of our API in the future. We use `defaults: { format: :json }` to ensure that the data returned from these routes is `JSON`.

#### Create jbuilder Files

Normally in Rails there is a corresponding `.erb` view file for each controller action. However, since we're building an API we need to create corresponding [jbuilder](https://github.com/rails/jbuilder) files for each controller actions.

> Jbuilder: generate JSON objects with a Builder-style DSL

1. In a new terminal window run the following commands.

   ```sh
   mkdir -p app/views/api/v1/todo_items
   touch app/views/api/v1/todo_items/_todo_item.json.jbuilder
   touch app/views/api/v1/todo_items/show.json.jbuilder
   touch app/views/api/v1/todo_items/index.json.jbuilder
   ```

2. Open `app/views/api/v1/todo_items/_todo_item.json.jbuilder` and add the following. This will serve as a reusable partial for other `.jbuilder` files.

   ```ruby
   # app/views/api/v1/todo_items/_todo_item.json.jbuilder

   json.extract! todo_item,
                 :id,
                 :title,
                 :user_id,
                 :complete,
                 :created_at,
                 :updated_at
   ```

   `json.extract!` is a method that takes an object (in this case a `TodoItem`), and a list of attributes we want to render into JSON.

3. Open `app/views/api/v1/todo_items/show.json.jbuilder` and add the following.

   ```ruby
   # app/views/api/v1/todo_items/show.json.jbuilder

   json.partial! "api/v1/todo_items/todo_item", todo_item: @todo_item
   ```

   `json.partial!` will render the `_todo_item.json.jbuilder` partial, and takes `@todo_item` as an argument. The `@todo_item` is handled through our private `set_todo_item` method in our controller.

4. Open `app/views/api/v1/todo_items/index.json.jbuilder` and add the following.

   ```ruby
   # app/views/api/v1/todo_items/index.json.jbuilder

   json.array! @todo_items, partial: "api/v1/todo_items/todo_item", as: :todo_item
   ```

   `json.array!` will take a list of queried `TodoItems` and pass each `TodoItem` into the `_todo_item.json.jbuilder` partial. We still need to add `@todo_items` into our controller `index` action.

#### Update Controller Actions

Now we need to update our controller actions so that we can pass data into our newly created `.jbuilder` files. For now, we're just going to updated the `index` action.

1. Open up `app/controllers/api/v1/todo_items_controller.rb` and add the following.

   ```ruby
   # app/controllers/api/v1/todo_items_controller.rb

   class Api::V1::TodoItemsController < ApplicationController
     def index
       @todo_items = TodoItem.all
     end
   end
   ```

If you open up a browser and navigate to [http://localhost:3000/api/v1/todo_items](http://localhost:3000/api/v1/todo_items) you should see the following.

![JSON output of todo items](/assets/images/posts/rails-react-tutorial/4.0.png)

If you open up a browser and navigate to [http://localhost:3000/api/v1/todo_items/1](http://localhost:3000/api/v1/todo_items/1) you should see the following.

![JSON output a todo item](/assets/images/posts/rails-react-tutorial/4.1.png)

### Authorize End Points

Now that we have a base for our API, you might have noticed a few problems.

1. A visitor does not need to be authenticated to visit these endpoints.
1. There is no association between a visitor and the `TodoItems` displayed.

This is a problem because it means a visitor to our site could go to [http://localhost:3000/api/v1/todo_items](http://localhost:3000/api/v1/todo_items) and see all of the site's data.

#### Lock Down The Controller

First we need to lock down our controller by authenticating all requests. Luckily devise has a [helper method](https://github.com/heartcombo/devise#controller-filters-and-helpers) that allows us to do just this.

1. Open up `app/controllers/api/v1/todo_items_controller.rb` and add `before_action :authenticate_user!`.

   ```ruby
   # app/controllers/api/v1/todo_items_controller.rb

   class Api::V1::TodoItemsController < ApplicationController
     before_action :authenticate_user!
     before_action :set_todo_item, only: %i[show edit update destroy]
   end
   ```

   Now that we're locking down our controller to only authenticated users, we need to associate the `User` with the `TodoItem`.

2. Open up `app/controllers/api/v1/todo_items_controller.rb` and add the following private method.

   <pre data-line="11-13">
     <code class="language-ruby">
       # app/controllers/api/v1/todo_items_controller.rb
       
       class Api::V1::TodoItemsController < ApplicationController
         private
       
         def set_todo_item
           @todo_item = TodoItem.find(params[:id])
         end
       
         def authorized?
           @todo_item.user == current_user
         end
       end
     </code>
   </pre>

   Devise has a [helper method](https://github.com/heartcombo/devise#controller-filters-and-helpers) called `current_user` that returns the current signed-in user. So, our private `authorized?` method will return `true` is the current `TodoItem` belongs to the `current_user`, and false otherwise.

   Now we need to handle any requests that are not authorized. Meaning, we need to handle any request where the `User` is trying to hit an endpoint that does not belong to them.

3. In a new terminal window, run the following commands.

   ```sh
   touch app/views/api/v1/todo_items/unauthorized.json.jbuilder
   ```

   This will create a new `.jbuilder` view to handle unauthorized requests.

4. Open `app/views/api/v1/todo_items/unauthorized.json.jbuilder` and add the following.

   ```ruby
   json.error "You are not authorized to perform this action."
   ```

   This will return a JSON object with an `error` key with a value of `"You are not authorized to perform this action."`. Now we need to create a method will conditionally render this view depending on whether or not the current request is authorized.

5. Open up `app/controllers/api/v1/todo_items_controller.rb` and add the following private method.

<pre data-line="15-19">
  <code class="language-ruby">
    # app/controllers/api/v1/todo_items_controller.rb
    
    class Api::V1::TodoItemsController < ApplicationController
      private
    
      def set_todo_item
        @todo_item = TodoItem.find(params[:id])
      end
    
      def authorized?
        @todo_item.user == current_user
      end
    
      def handle_unauthorized
        unless authorized?
          respond_to { |format| format.json { render :unauthorized, status: 401 } }
        end
      end
    end
  </code>
</pre>

This method checks to see if the request is authorized by calling our `authorized?` private method. If the request is not authorized, we return our `unauthorized.json.jbuilder` view. Note that we also pass a `status` of `401`.

> It's our responsibly to return the correct [HTTP status code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) when building our API.

#### Update The Index Action

Right now we're just displaying all `TodoItems` through the `index` action, when we really need to display the current `User's` `TodoItems`

1. Open up `app/controllers/api/v1/todo_items_controller.rb` and add the following.

```ruby
# app/controllers/api/v1/todo_items_controller.rb

class Api::V1::TodoItemsController < ApplicationController
  def index
    @todo_items = current_user.todo_items.all
  end
end
```

As a test, make sure to [logout of](http://localhost:3000/users/sign_out) of the application. Once logged out, visit [http://localhost:3000/api/v1/todo_items](http://localhost:3000/api/v1/todo_items). You should see the following.

![error response](/assets/images/posts/rails-react-tutorial/4.2.png)

This response is handled through the `unauthorized.json.jbuilder` view. Furthermore, if you were to check the network response, you'll see that it returns a `401`.

![network response](/assets/images/posts/rails-react-tutorial/4.3.png)

You'll remember that our private `handle_unauthorized` method not only renders the `unauthorized.json.jbuilder` view, but also returns a `401` status.

Finally, if you [login](http://localhost:3000/users/sign_in) as `user-1@example.com` and visit [http://localhost:3000/api/v1/todo_items](http://localhost:3000/api/v1/todo_items), you should only see `TodoItems` related to you.

![related todo_items](/assets/images/posts/rails-react-tutorial/4.4.png)

#### Update The Show Action

Now let's update the empty `show` action.

1. Open up `app/controllers/api/v1/todo_items_controller.rb` and add the following.

```ruby
# app/controllers/api/v1/todo_items_controller.rb

class Api::V1::TodoItemsController < ApplicationController
  def show
    if authorized?
      respond_to { |format| format.json { render :show } }
    else
      handle_unauthorized
    end
  end
end
```

Since we're running `before_action :authenticate_user!` before all our actions, we know that a visitor must be authenticated before they can view a `TodoItem`. However, we need to prevent a visitor from accessing `TodoItems` that do not belong to them. We check if the current use is authorized with the `authorized?` private method. If they are, we return `app/views/api/v1/todo_items/show.json.jbuilder`, otherwise we return `app/views/api/v1/todo_items/unauthorized.json.jbuilder`.

As a test, [login](http://localhost:3000/users/sign_in) as `user-1@example.com` and visit [http://localhost:3000/api/v1/todo_items/1](http://localhost:3000/api/v1/todo_items/1). You should see the following.

![a single todo_item JSON response](/assets/images/posts/rails-react-tutorial/4.5.png)

Now visit a path the belongs to another `User`. Assuming you're logged in as `user-1@example.com`, visit [http://localhost:3000/api/v1/todo_items/20](http://localhost:3000/api/v1/todo_items/20). You should see the following.

![unauthorized response](/assets/images/posts/rails-react-tutorial/4.6.png)

#### Update The Create Action

Now we need a way to create `TodoItems` with our API.

1. Open up `app/controllers/api/v1/todo_items_controller.rb` and add the following.

   ```ruby
   # app/controllers/api/v1/todo_items_controller.rb

   class Api::V1::TodoItemsController < ApplicationController
     def create
       @todo_item = current_user.todo_items.build(todo_item_params)

       if authorized?
         respond_to do |format|
           if @todo_item.save
             format.json do
               render :show,
                      status: :created,
                      location: api_v1_todo_item_path(@todo_item)
             end
           else
             format.json do
               render json: @todo_item.errors, status: :unprocessable_entity
             end
           end
         end
       else
         handle_unauthorized
       end
     end

     private

     def todo_item_params
       params.require(:todo_item).permit(:title, :complete)
     end
   end
   ```

   First we create a new `@todo_item` instance variable that [builds](https://guides.rubyonrails.org/association_basics.html#methods-added-by-has-many) a new `TodoItem` from the `current_user`. We pass in `todo_item_params`, which we declare as a private method. This concept is called [strong parameters](https://guides.rubyonrails.org/action_controller_overview.html#strong-parameters), and prevents mass assignment.

   If the request is `authorized?`, we then try to post the record to the database. If the item successfully saves, we pass the new `@todo_item` into `app/views/api/v1/todo_items/show.json.jbuilder` and which will return the new `@todo_item`. Note that we also return a `status` of `created`. If the `@todo_item` does not save, we render the errors, and return a `status` of `unprocessable_entity`.

   Since we don't have a front-end yet, there's no way for us to create a new `TodoItem` in the browser. However, we can still test that the `create` action is working by using the developer console.

1. First, [login to the application](http://localhost:3000/users/sign_in) as **user-1@example.com**.
1. Then, navigate to the [homepage](http://localhost:3000/).
1. Open up the developer console and paste the following and hit enter.

   ```javascript
   var csrfToken = document.querySelector("[name=csrf-token]");
   fetch("http://localhost:3000/api/v1/todo*items", {
     credentials: "include",
     headers: {
       accept: "application/json, text/plain, */_",
       "accept-language": "en-US,en;q=0.9",
       "cache-control": "no-cache",
       "content-type": "application/json;charset=UTF-8",
       pragma: "no-cache",
       "sec-fetch-dest": "empty",
       "sec-fetch-mode": "cors",
       "sec-fetch-site": "same-origin",
       "x-csrf-token": csrfToken.content,
     },
     referrer: "http://localhost:3000/",
     referrerPolicy: "strict-origin-when-cross-origin",
     body: '{"todo_item":{"title":"A new todo item","complete":false}}',
     method: "POST",
     mode: "cors",
   });
   ```

   For reference, it should look like the following.

   ![developer console](/assets/images/posts/rails-react-tutorial/4.8.png)

   To verify that the new `TodoItem` was saved, navigate to [http://localhost:3000/api/v1/todo_items](http://localhost:3000/api/v1/todo_items).

   ![todo index](/assets/images/posts/rails-react-tutorial/4.10.png)

   Don't get too bogged down on this since it's really just a demonstration. All we're doing is manually making a `POST` request to our API. Our React application will take care of this for us. One thing to note is that we have to pass the `x-csrf-token` into the `header`. This concept has nothing to do with React, and is a [Rails convention](https://guides.rubyonrails.org/security.html#csrf-countermeasures) for securing an application.

   > By default, Rails includes an unobtrusive scripting adapter, which adds a header called X-CSRF-Token with the security token on every non-GET Ajax call. Without this header, non-GET Ajax requests won't be accepted by Rails. When using another library to make Ajax calls, it is necessary to add the security token as a default header for Ajax calls in your library. To get the token, have a look at <meta name='csrf-token' content='THE-TOKEN'> tag printed by <%= csrf_meta_tags %> in your application view.

   On every page of our Rails application, there is a `meta_tag` with a `csrf-token`. This token needs to be passed into any request, which is what `var csrfToken = document.querySelector('[name=csrf-token]');` does.

   ![csrf-token](/assets/images/posts/rails-react-tutorial/4.7.png)

   As a final test, let's post an invalid `TodoItem` to ensure it is not saved.

1. Assuming you're still logged into the application, open up the developer console and paste the following and hit enter. Note that `body: '{"todo_item":{"title":"","complete":false}}',` has a blank `title`. This is not valid according to our validation in `app/models/todo_item.rb`.

<pre data-line="18">
  <code class="language-javascript">
    var csrfToken = document.querySelector("[name=csrf-token]");
    fetch("http://localhost:3000/api/v1/todo/items", {
      credentials: "include",
      headers: {
        accept: "application/json, text/plain, /_",
        "accept-language": "en-US,en;q=0.9",
        "cache-control": "no-cache",
        "content-type": "application/json;charset=UTF-8",
        pragma: "no-cache",
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin",
        "x-csrf-token": csrfToken.content,
      },
      referrer: "http://localhost:3000/",
      referrerPolicy: "strict-origin-when-cross-origin",
      body: '{"todo_item":{"title":"","complete":false}}',
      method: "POST",
      mode: "cors",
    });
  </code>
</pre>

If you open up your network tab you should see the following under **Headers**

![header response](/assets/images/posts/rails-react-tutorial/4.11.png)

Furthermore, if you look under **Response** you'll see the response.

![preview response](/assets/images/posts/rails-react-tutorial/4.12.png)

#### Update The Update Action

Building our `update` action will be similar to the steps to updating our `create` action.

1. Open up `app/controllers/api/v1/todo_items_controller.rb` and add the following.

   ```ruby
   # app/controllers/api/v1/todo_items_controller.rb

   class Api::V1::TodoItemsController < ApplicationController
     def update
       if authorized?
         respond_to do |format|
           if @todo_item.update(todo_item_params)
             format.json do
               render :show,
                      status: :ok,
                      location: api_v1_todo_item_path(@todo_item)
             end
           else
             format.json do
               render json: @todo_item.errors, status: :unprocessable_entity
             end
           end
         end
       else
         handle_unauthorized
       end
     end
   end
   ```

   If the request is `authorized?`, we then try to post the record to the database. If the item successfully saves, we pass the updated `@todo_item` into `app/views/api/v1/todo_items/show.json.jbuilder` and which will return the updated `@todo_item`. Note that we also return a `status` of `ok`. If the `@todo_item` does not save, we render the errors, and return a `status` of `unprocessable_entity`.

   Since we don't have a front-end yet, there's no way for us to update a existing `TodoItem` in the browser. However, we can still test that the `update` action is working by using the developer console.

1. First, [login to the application](http://localhost:3000/users/sign_in) as **user-1@example.com**.
1. Then, navigate to the [homepage](http://localhost:3000/).
1. Open up the developer console and paste the following and hit enter. Make sure that [http://localhost:3000/api/v1/todo_items/1](http://localhost:3000/api/v1/todo_items/1) exists first.

   ```javascript
   var csrfToken = document.querySelector("[name=csrf-token]");
   fetch("http://localhost:3000/api/v1/todo*items/1", {
     credentials: "include",
     headers: {
       accept: "application/json, text/plain, */_",
       "accept-language": "en-US,en;q=0.9",
       "cache-control": "no-cache",
       "content-type": "application/json;charset=UTF-8",
       pragma: "no-cache",
       "sec-fetch-dest": "empty",
       "sec-fetch-mode": "cors",
       "sec-fetch-site": "same-origin",
       "x-csrf-token": csrfToken.content,
     },
     referrer: "http://localhost:3000/",
     referrerPolicy: "strict-origin-when-cross-origin",
     body: '{"todo_item":{"title":"To Do Item 1 for user-1@example.com UPDATED","complete":false}}',
     method: "PUT",
     mode: "cors",
   });
   ```

   For reference, it should look like the following.

   ![developer console](/assets/images/posts/rails-react-tutorial/4.13.png)

   To verify that the `TodoItem` was updated, navigate to [http://localhost:3000/api/v1/todo_items/1](http://localhost:3000/api/v1/todo_items/1).

   ![updated todo item](/assets/images/posts/rails-react-tutorial/4.14.png)

   As a final test, let's post an invalid `TodoItem` to ensure it is not saved.

1. Assuming you're still logged into the application, open up the developer console and paste the following and hit enter. Note that `body: '{"todo_item":{"title":"","complete":false}}',` has a blank `title`. This is not valid according to our validation in `app/models/todo_item.rb`.

<pre data-line="18-19">
  <code class="language-javascript">
    var csrfToken = document.querySelector("[name=csrf-token]");
    fetch("http://localhost:3000/api/v1/todo*items/1", {
      credentials: "include",
      headers: {
        accept: "application/json, text/plain, */_",
        "accept-language": "en-US,en;q=0.9",
        "cache-control": "no-cache",
        "content-type": "application/json;charset=UTF-8",
        pragma: "no-cache",
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin",
        "x-csrf-token": csrfToken.content,
      },
      referrer: "http://localhost:3000/",
      referrerPolicy: "strict-origin-when-cross-origin",
      body: '{"todo_item":{"title":"","complete":false}}',
      method: "PUT",
      mode: "cors",
    });
  </code>
</pre>

If you open up your network tab you should see the following under **Headers**

![header response](/assets/images/posts/rails-react-tutorial/4.15.png)

Furthermore, if you look under **Response** you'll see the response.

![preview response](/assets/images/posts/rails-react-tutorial/4.16.png)

#### Update The Update Destroy

Now all we need to do is update our `destroy` action.

1. Open up `app/controllers/api/v1/todo_items_controller.rb` and add the following.

   ```ruby
   # app/controllers/api/v1/todo_items_controller.rb

   class Api::V1::TodoItemsController < ApplicationController
     def destroy
       if authorized?
         @todo_item.destroy
         respond_to { |format| format.json { head :no_content } }
       else
         handle_unauthorized
       end
     end
   end
   ```

   If the request is `authorized?`, we then destroy the record. If the item is successfully destroyed, we return a `status` of `no_content`.

   Since we don't have a front-end yet, there's no way for us to destroy an existing `TodoItem` in the browser. However, we can still test that the `destroy` action is working by using the developer console.

1. First, [login to the application](http://localhost:3000/users/sign_in) as **user-1@example.com**.
1. Then, navigate to the [homepage](http://localhost:3000/).
1. Open up the developer console and paste the following and hit enter. Make sure that [http://localhost:3000/api/v1/todo_items/1](http://localhost:3000/api/v1/todo_items/1) exists first.

   ```javascript
   var csrfToken = document.querySelector("[name=csrf-token]");
   fetch("http://localhost:3000/api/v1/todo*items/1", {
     credentials: "include",
     headers: {
       accept: "application/json, text/plain, */_",
       "accept-language": "en-US,en;q=0.9",
       "cache-control": "no-cache",
       pragma: "no-cache",
       "sec-fetch-dest": "empty",
       "sec-fetch-mode": "cors",
       "sec-fetch-site": "same-origin",
       "x-csrf-token": csrfToken.content,
     },
     referrer: "http://localhost:3000/",
     referrerPolicy: "strict-origin-when-cross-origin",
     body: null,
     method: "DELETE",
     mode: "cors",
   });
   ```

   For reference, it should look like the following.

   ![developer console](/assets/images/posts/rails-react-tutorial/4.17.png)

   If you open up your network tab you should see the following under **Headers**

   ![header response](/assets/images/posts/rails-react-tutorial/4.18.png)

   To confirm the `TodoItem` was successfully destroyed, navigate to [http://localhost:3000/api/v1/todo_items/1](http://localhost:3000/api/v1/todo_items/1). You should see the following.

   ![missing record](/assets/images/posts/rails-react-tutorial/4.19.png)

   As a final test, let's confirm we cannot destroy another `User`'s `TodoItem`.

1. Assuming you're still logged into the application, open up the developer console and paste the following and hit enter. Note that the url is now `http://localhost:3000/api/v1/todo_items/20`, which does not belong to **user-1@example.com**.

<pre data-line="3">
  <code class="language-javascript">
    var csrfToken = document.querySelector("[name=csrf-token]");
    fetch("http://localhost:3000/api/v1/todo*items/20", {
      credentials: "include",
      headers: {
        accept: "application/json, text/plain, */_",
        "accept-language": "en-US,en;q=0.9",
        "cache-control": "no-cache",
        pragma: "no-cache",
        "sec-fetch-dest": "empty",
        "sec-fetch-mode": "cors",
        "sec-fetch-site": "same-origin",
        "x-csrf-token": csrfToken.content,
      },
      referrer: "http://localhost:3000/",
      referrerPolicy: "strict-origin-when-cross-origin",
      body: null,
      method: "DELETE",
      mode: "cors",
    });
  </code>
</pre>

If you open up your network tab you should see the following under **Headers**

![header response](/assets/images/posts/rails-react-tutorial/4.20.png)

Furthermore, if you look under **Response** you'll see the response.

![preview response](/assets/images/posts/rails-react-tutorial/4.21.png)

## Step 5: Create a React Application

Now that we have a fully functioning API, we can create our front-end in React. Before we get started, let's remove the sample React application that was created when we generated our Rails application. I recommend you install [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi), as it will help you debug.

1. In a new terminal window, run `rm app/javascript/packs/hello_react.jsx`.
2. Open `app/javascript/packs/application.js` and remove the `require("./hello_react");` line.

If you open up a browser and navigate to [http://localhost:3000/](http://localhost:3000/) you should no longer see the `Hello React!` message on the bottom of the page.

![homepage without React](/assets/images/posts/rails-react-tutorial/5.0.png)

### Create TodoApp Component

Let's start off by creating our base component which will contain our React application.

1. In a new terminal window, run the following commands.

   ```sh
   mkdir app/javascript/packs/components
   touch app/javascript/packs/components/TodoApp.jsx
   ```

2. Open `TodoApp.jsx` and add the following.

   ```javascript
   // app/javascript/packs/components/TodoApp.jsx
   import React from "react";
   import ReactDOM from "react-dom";

   class TodoApp extends React.Component {
     render() {
       return <p>TodoApp</p>;
     }
   }

   document.addEventListener("turbolinks:load", () => {
     const app = document.getElementById("todo-app");
     app && ReactDOM.render(<TodoApp />, app);
   });
   ```

   > Note that we only mount our React application once the `turbolinks:load` event has fired. This a specific to Rails, since Rails ships with [Turbolinks](https://github.com/turbolinks/turbolinks).

3. Open `app/views/pages/my_todo_items.html.erb` and replace the contents of the file with the following.

   ```erb
   <%# app/views/pages/my_todo_items.html.erb %>

   <h1>My To Do Items</h1>
   <div id="todo-app"></div>
   ```

4. Open `app/javascript/packs/application.js` and add `require("./components/TodoApp");`

   ```javascript
   // app/javascript/packs/application.js

   require("./components/TodoApp");
   require("bootstrap");
   import "bootstrap/dist/css/bootstrap";
   ```

If you [login](http://localhost:3000/users/sign_in) to the application and visit [http://localhost:3000/](http://localhost:3000/) you should see that **"TodoApp"** has loaded.

![TodoApp loaded](/assets/images/posts/rails-react-tutorial/5.1.png)

### Display TodoItems

Now we want to display our `TodoItems` in our `TodoApp`.

#### Create TodoItems and TodoItem Components

1. In a new terminal window, run `touch app/javascript/packs/components/TodoItems.jsx`.
2. Add the following to `app/javascript/packs/components/TodoItems.jsx`.

   ```javascript
   // app/javascript/packs/components/TodoItems.jsx
   import React from "react";

   class TodoItems extends React.Component {
     constructor(props) {
       super(props);
     }
     render() {
       return (
         <>
           <div className="table-responsive">
             <table className="table">
               <thead>
                 <tr>
                   <th scope="col">Status</th>
                   <th scope="col">Item</th>
                   <th scope="col" className="text-right">
                     Actions
                   </th>
                 </tr>
               </thead>
               <tbody>{this.props.children}</tbody>
             </table>
           </div>
         </>
       );
     }
   }
   export default TodoItems;
   ```

   The `<TodoItems>` component is simply a `table` that will hold individual `<TodoItems>` via `{this.props.children}`.

3. In a new terminal window, run `touch app/javascript/packs/components/TodoItem.jsx`.
4. Add the following to `app/javascript/packs/components/TodoItem.jsx`.

   ```js
   // app/javascript/packs/components/TodoItem.jsx
   import React from "react";
   import PropTypes from "prop-types";

   class TodoItem extends React.Component {
     constructor(props) {
       super(props);
       this.state = {
         complete: this.props.todoItem.complete,
       };
     }
     render() {
       const { todoItem } = this.props;
       return (
         <tr className={`${this.state.complete ? "table-light" : ""}`}>
           <td>
             <svg
               className={`bi bi-check-circle ${
                 this.state.complete ? `text-success` : `text-muted`
               }`}
               width="2em"
               height="2em"
               viewBox="0 0 20 20"
               fill="currentColor"
               xmlns="http://www.w3.org/2000/svg"
             >
               <path
                 fillRule="evenodd"
                 d="M17.354 4.646a.5.5 0 010 .708l-7 7a.5.5 0 01-.708 0l-3-3a.5.5 0 11.708-.708L10 11.293l6.646-6.647a.5.5 0 01.708 0z"
                 clipRule="evenodd"
               />
               <path
                 fillRule="evenodd"
                 d="M10 4.5a5.5 5.5 0 105.5 5.5.5.5 0 011 0 6.5 6.5 0 11-3.25-5.63.5.5 0 11-.5.865A5.472 5.472 0 0010 4.5z"
                 clipRule="evenodd"
               />
             </svg>
           </td>
           <td>
             <input
               type="text"
               defaultValue={todoItem.title}
               disabled={this.state.complete}
               className="form-control"
               id={`todoItem__title-${todoItem.id}`}
             />
           </td>
           <td className="text-right">
             <div className="form-check form-check-inline">
               <input
                 type="boolean"
                 defaultChecked={this.state.complete}
                 type="checkbox"
                 className="form-check-input"
                 id={`complete-${todoItem.id}`}
               />
               <label
                 className="form-check-label"
                 htmlFor={`complete-${todoItem.id}`}
               >
                 Complete?
               </label>
             </div>
             <button className="btn btn-outline-danger">Delete</button>
           </td>
         </tr>
       );
     }
   }

   export default TodoItem;

   TodoItem.propTypes = {
     todoItem: PropTypes.object.isRequired,
   };
   ```

#### Fetch Todo Items from the API

1. In a new terminal window run `yarn add axios`.
2. Open `app/javascript/packs/components/TodoApp.jsx` and add the following.

   <pre data-line="5-10">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoApp.jsx
       
       class TodoApp extends React.Component {
         constructor(props) {
           super(props);
           this.state = {
             todoItems: [],
           };
         }
         render() {
           return &lt;p&gt;TodoApp&lt;/p&gt;;
         }
       }
     </code>
   </pre>

   We need to create an empty `state` array that will hold our `<TodoItems>`.

3. Import `axios` into the `<TodoApp>` component.

   ```js
   // app/javascript/packs/components/TodoApp.jsx
   import React from "react";
   import ReactDOM from "react-dom";

   import axios from "axios";
   class TodoApp extends React.Component {}
   ```

4. Load `TodoItems` into `state`.

<pre data-line="13, 15-28">
  <code class="language-javascript">
    // app/javascript/packs/components/TodoApp.jsx
    import React from "react";
    import ReactDOM from "react-dom";
    
    import axios from "axios";
    class TodoApp extends React.Component {
      constructor(props) {
        super(props);
        this.state = {
          todoItems: [],
        };
        this.getTodoItems = this.getTodoItems.bind(this);
      }
      componentDidMount() {
        this.getTodoItems();
      }
      getTodoItems() {
        axios
          .get("/api/v1/todo_items")
          .then((response) => {
            const todoItems = response.data;
            this.setState({ todoItems });
          })
          .catch((error) => {
            console.log(error);
          });
      }
    }
  </code>
</pre>

This is a big step, so let's go over it piece be piece.

- First we create a `getTodoItems` method that hits our API's `index` action at `/api/v1/todo_items`.
- If the request is successful, we load that data into `state` via `this.setState({ todoItems });`, otherwise we log the error.
- Then, we call `getTodoItems()` when the `<TodoApp>` component loads via the `componentDidMount()` call.
- Finally, we bind `getTodoItems` in order for the keyword `this` to work in our `componentDidMount()` callback.

If you open your React developer tools, you should see that the `todoItems` state array has items.

![todoItems state](/assets/images/posts/rails-react-tutorial/5.2.png)

#### Render TodoItem and TodoItem Components

Now that we're successfully updating state, let's render the `TodoItems` and `TodoItem` in our application.

1. Open `app/javascript/packs/components/TodoApp.jsx` and add the following.

<pre data-line="8-9, 33-39">
  <code class="language-javascript">
    // app/javascript/packs/components/TodoApp.jsx
    import React from "react";
    import ReactDOM from "react-dom";
    
    import axios from "axios";
    
    import TodoItems from "./TodoItems";
    import TodoItem from "./TodoItem";
    class TodoApp extends React.Component {
      constructor(props) {
        super(props);
        this.state = {
          todoItems: [],
        };
        this.getTodoItems = this.getTodoItems.bind(this);
      }
      componentDidMount() {
        this.getTodoItems();
      }
      getTodoItems() {
        axios
          .get("/api/v1/todo_items")
          .then((response) =&gt; {
            const todoItems = response.data;
            this.setState({ todoItems });
          })
          .catch((error) =&gt; {
            console.log(error);
          });
      }
      render() {
        return (
          &lt;TodoItems&gt;
            {this.state.todoItems.map((todoItem) =&gt; (
              &lt;TodoItem key={todoItem.id} todoItem={todoItem} /&gt;
            ))}
          &lt;/TodoItems&gt;
        );
      }
    }
  </code>
</pre>

- First we import the `<TodoItems>` and `<TodoItem>` components.
- Then we display them via our `render` method.
- We use `Array.map` to map over each `todoItem` in `this.state.todoItems`, making sure to pass a unique value into the `key` attribute. Since our Rails application automatically assigns a unique value to each `id` column in the database, we can use `todoItem.id`. Finally, we pass the `todoItem` Object into the `todoItem` attribute as props.

If you [login](http://localhost:3000/users/sign_in) to the application and visit [http://localhost:3000/](http://localhost:3000/) you should see that our items are loading.

![TodoApp loaded](/assets/images/posts/rails-react-tutorial/5.3.png)

### Creating TodoItems

Now that we've loaded our `TodoItems` into our application, we need a way to add more.

#### Create TodoForm

1. In a new terminal window run `touch app/javascript/packs/components/TodoForm.jsx` and add the following.

   ```js
   // app/javascript/packs/components/TodoForm.jsx
   import React from "react";
   import PropTypes from "prop-types";

   import axios from "axios";
   class TodoForm extends React.Component {
     constructor(props) {
       super(props);
       this.handleSubmit = this.handleSubmit.bind(this);
       this.titleRef = React.createRef();
     }

     handleSubmit(e) {
       e.preventDefault();
       axios
         .post("/api/v1/todo_items", {
           todo_item: {
             title: this.titleRef.current.value,
             complete: false,
           },
         })
         .then((response) => {
           const todoItem = response.data;
           this.props.createTodoItem(todoItem);
         })
         .catch((error) => {
           console.log(error);
         });
       e.target.reset();
     }

     render() {
       return (
         <form onSubmit={this.handleSubmit} className="my-3">
           <div className="form-row">
             <div className="form-group col-md-8">
               <input
                 type="text"
                 name="title"
                 ref={this.titleRef}
                 required
                 className="form-control"
                 id="title"
                 placeholder="Write your todo item here..."
               />
             </div>
             <div className="form-group col-md-4">
               <button className="btn btn-outline-success btn-block">
                 Add To Do Item
               </button>
             </div>
           </div>
         </form>
       );
     }
   }

   export default TodoForm;

   TodoForm.propTypes = {
     createTodoItem: PropTypes.func.isRequired,
   };
   ```

- We create a [ref](https://reactjs.org/docs/refs-and-the-dom.html#creating-refs) via `this.titleRef = React.createRef();` and `ref={this.titleRef}` in order to access data on the `input` field.
- We create a `handleSubmit` function that is called when our form is submitted via `onSubmit={this.handleSubmit}`. To ensure the method is called, we add `this.handleSubmit = this.handleSubmit.bind(this);` to our `constructor`.
- The `handleSubmit` method prevents the form from submitting by default via `e.preventDefault();`, and instead makes a POST request to the `create` action on our API via axios. If the request is successful, we create a new `TodoItem` by calling `this.props.createTodoItem(todoItem);`. Note that we have not created this method yet.
- Note that we need to format out POST request as follows, as this is how Rails expects to receive the POST request. Be sure to set `complete` to `false`, since a user wouldn't be adding a completed `TodoItem` to their list.

  ```json
  todo_item: {
  title: this.titleRef.current.value,
  complete: false
  }
  ```

#### Create createTodoItem Method

Now we need to create a method that will update our application's `state` which will then allow the new `TodoItem` to be rendered to the page.

1. Open up `app/javascript/packs/components/TodoApp.jsx` and add the following.

<pre data-line="10, 18, 21-24, 27-28, 34">
  <code class="language-javascript">
    // app/javascript/packs/components/TodoApp.jsx
    import React from "react";
    import ReactDOM from "react-dom";
    
    import axios from "axios";
    
    import TodoItems from "./TodoItems";
    import TodoItem from "./TodoItem";
    import TodoForm from "./TodoForm";
    class TodoApp extends React.Component {
      constructor(props) {
        super(props);
        this.state = {
          todoItems: [],
        };
        this.getTodoItems = this.getTodoItems.bind(this);
        this.createTodoItem = this.createTodoItem.bind(this);
      }
    
      createTodoItem(todoItem) {
        const todoItems = [todoItem, ...this.state.todoItems];
        this.setState({ todoItems });
      }
      render() {
        return (
          <>
            <TodoForm createTodoItem={this.createTodoItem} />
            <TodoItems>
              {this.state.todoItems.map((todoItem) => (
                <TodoItem key={todoItem.id} todoItem={todoItem} />
              ))}
            </TodoItems>
          </>
        );
      }
    }
  </code>
</pre>

- First we import our `<TodoForm>` component.
- Then we bind `createTodoItem` in order for the keyword `this` to work when called in the `<TodoForm>` component.
- Next we create our `createTodoItem` method which takes in a `todoItem` object. We create a new array to ensure we don't [mutate](https://reactjs.org/docs/react-component.html#state) state.
  - Note that we use the [spread syntax](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Spread_syntax#Spread_in_array_literals) to build our new array.
  - Note that we also place the new `todoItem` first in the array, since we're displaying our `TodoItems` in the order in which they were created. You'll remember our `default_scope` is set to `order(created_at: :desc)` in `app/models/todo_item.rb`.
- Finally, we add our `<TodoForm>` component to the `render` method.
  - We add a `createTodoItem` prop and pass it the `createTodoItem` method in order for the form to updated state.
  - Note that we wrap the output in `<></>`, which is a [React fragment](https://reactjs.org/docs/fragments.html#short-syntax).

If you [login](http://localhost:3000/users/sign_in) to the application and visit [http://localhost:3000/](http://localhost:3000/) you should see that the `TodoForm` is loading.

![TodoForm loaded](/assets/images/posts/rails-react-tutorial/5.4.png)

However, if you try to add a new item, you'll notice that it doesn't work. This is because we need to account for the [CSRF Countermeasures](https://guides.rubyonrails.org/security.html#csrf-countermeasures).

![CSRF error](/assets/images/posts/rails-react-tutorial/5.5.gif)

#### Account for csrf-token

On every page of our Rails application, there is a `meta_tag` with a `csrf-token`. This token needs to be passed into any request, which is what `var csrfToken = document.querySelector('[name=csrf-token]');` does.

![csrf-token](/assets/images/posts/rails-react-tutorial/4.7.png)

Since our application requires us to pass a `csrf-token` into the `header` of any `post` request, we need to create a new component.

1. In a new terminal window run `touch app/javascript/packs/components/AxiosHeaders.jsx` and add the following.

   ```js
   // app/javascript/packs/components/AxiosHeaders.jsx
   import axios from "axios";

   const setAxiosHeaders = () => {
     const csrfToken = document.querySelector("[name=csrf-token]");
     if (!csrfToken) {
       return;
     }
     const csrfTokenContent = csrfToken.content;
     csrfTokenContent &&
       (axios.defaults.headers.common["X-CSRF-TOKEN"] = csrfTokenContent);
   };

   export default setAxiosHeaders;
   ```

   - First we search for the `meta` tag that contains the `csrf-token` and save it to `csrfToken`.
   - If the page doesn't contain a `csrf-token`, we stop the function. Otherwise, we see if the the `csrf-token` has a `content` key, and use that value in our `header`.

2. Next, open `app/javascript/packs/components/TodoForm.jsx` and add the following.

   <pre data-line="7,17">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoForm.jsx
       import React from "react";
       import PropTypes from "prop-types";
       
       import axios from "axios";
       import setAxiosHeaders from "./AxiosHeaders";
       class TodoForm extends React.Component {
         constructor(props) {
           super(props);
           this.handleSubmit = this.handleSubmit.bind(this);
           this.titleRef = React.createRef();
         }
       
         handleSubmit(e) {
           e.preventDefault();
           setAxiosHeaders();
         }
       }
     </code>
   </pre>

   - Here we're simply importing our `<setAxiosHeaders>` component, and calling it before we make our `post` request.

Now if you try and add a new `TodoItem`, it should successfully load.

![successfully adding a todo item](/assets/images/posts/rails-react-tutorial/5.6.gif)

### Deleting TodoItems

Now that we're able to add `TodoItems`, let's create the ability to have them removed.

1. Open `app/javascript/packs/components/TodoItem.jsx` and add the following.

   <pre data-line="6-7,14-15,17-30">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoItem.jsx
       import React from "react";
       import PropTypes from "prop-types";
       
       import axios from "axios";
       import setAxiosHeaders from "./AxiosHeaders";
       class TodoItem extends React.Component {
         constructor(props) {
           super(props);
           this.state = {
             complete: this.props.todoItem.complete,
           };
           this.handleDestroy = this.handleDestroy.bind(this);
           this.path = `/api/v1/todo_items/${this.props.todoItem.id}`;
         }
         handleDestroy() {
           setAxiosHeaders();
           const confirmation = confirm("Are you sure?");
           if (confirmation) {
             axios
               .delete(this.path)
               .then((response) => {
                 this.props.getTodoItems();
               })
               .catch((error) => {
                 console.log(error);
               });
           }
         }
         render() {
           const { todoItem } = this.props;
           return (
             <button onClick={this.handleDestroy} className="btn btn-outline-danger">
               Delete
             </button>
           );
         }
       }
       
       export default TodoItem;
       
       TodoItem.propTypes = {
         todoItem: PropTypes.object.isRequired,
         getTodoItems: PropTypes.func.isRequired,
       };
     </code>
   </pre>

   - First we import both `axios` and `setAxiosHeaders` so that we'll be able to make requests to our API.
   - Then we bind `handleDestroy` in order for the keyword `this` to work when called in the Delete `button`.
   - We store the API endpoint of the `TodoItem` in `this.path` within the `constructor` function. This will be helpful later when we need to update our `TodoItems`.
   - We create a `handleDestroy` method that sends a `delete` request to the API. If the request is successful, then we render the `TodoItems`. Note that we need to add the `getTodoItems` `prop` to our component.
   - To avoid the user accidently deleting a `TodoItem`, we add a confirmation message first.
   - Finally, we require that the `getTodoItems` prop is set. Note that we still need to do this.

2. Next, open `app/javascript/packs/components/TodoApp.jsx` and add the following.

   <pre data-line="16">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoApp.jsx
       
       class TodoApp extends React.Component {
         constructor(props) {}
       
         render() {
           return (
             &lt;&gt;
               &lt;TodoForm createTodoItem={this.createTodoItem} /&gt;
               &lt;TodoItems&gt;
                 {this.state.todoItems.map((todoItem) =&gt; (
                   &lt;TodoItem
                     key={todoItem.id}
                     todoItem={todoItem}
                     getTodoItems={this.getTodoItems}
                   /&gt;
                 ))}
               &lt;/TodoItems&gt;
             &lt;/&gt;
           );
         }
       }
     </code>
   </pre>

   - Here we simply add a `getTodoItems` prop to the `<TodoItem>` component. This allows the `<TodoItem>` component to update state.

If you [login](http://localhost:3000/users/sign_in) to the application and visit [http://localhost:3000/](http://localhost:3000/) you should see that you're now able to delete `TodoItems`.

![deleting a todo item](/assets/images/posts/rails-react-tutorial/5.7.gif)

### Updating TodoItems

Now that we're able to create and destroy `TodoItems`, let's add the ability to edit them.

1. Open up `app/javascript/packs/components/TodoItem.jsx` and add the following.

   <pre data-line="6-9,11-28,40-41,52-53">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoItem.jsx
       
       class TodoItem extends React.Component {
         constructor(props) {
           this.handleChange = this.handleChange.bind(this);
           this.updateTodoItem = this.updateTodoItem.bind(this);
           this.inputRef = React.createRef();
           this.completedRef = React.createRef();
         }
         handleChange() {
           this.updateTodoItem();
         }
         updateTodoItem() {
           this.setState({ complete: this.completedRef.current.checked });
           setAxiosHeaders();
           axios
             .put(this.path, {
               todo_item: {
                 title: this.inputRef.current.value,
                 complete: this.completedRef.current.checked,
               },
             })
             .then((response) =&gt; {})
             .catch((error) =&gt; {
               console.log(error);
             });
         }
       
         render() {
           const { todoItem } = this.props;
           return (
             &lt;tr className={`${this.state.complete ? &quot;table-light&quot; : &quot;&quot;}`}&gt;
               &lt;td&gt;&lt;/td&gt;
               &lt;td&gt;
                 &lt;input
                   type=&quot;text&quot;
                   defaultValue={todoItem.title}
                   disabled={this.state.complete}
                   onChange={this.handleChange}
                   ref={this.inputRef}
                   className=&quot;form-control&quot;
                   id={`todoItem__title-${todoItem.id}`}
                 /&gt;
               &lt;/td&gt;
               &lt;td className=&quot;text-right&quot;&gt;
                 &lt;div className=&quot;form-check form-check-inline&quot;&gt;
                   &lt;input
                     type=&quot;boolean&quot;
                     defaultChecked={this.state.complete}
                     type=&quot;checkbox&quot;
                     onChange={this.handleChange}
                     ref={this.completedRef}
                     className=&quot;form-check-input&quot;
                     id={`complete-${todoItem.id}`}
                   /&gt;
                   &lt;label
                     className=&quot;form-check-label&quot;
                     htmlFor={`complete-${todoItem.id}`}
                   &gt;
                     Complete?
                   &lt;/label&gt;
                 &lt;/div&gt;
                 &lt;button
                   onClick={this.handleDestroy}
                   className=&quot;btn btn-outline-danger&quot;
                 &gt;
                   Delete
                 &lt;/button&gt;
               &lt;/td&gt;
             &lt;/tr&gt;
           );
         }
       }
       
       export default TodoItem;
     </code>
   </pre>

   - First, we bind `handleChange` and `updateTodoItem` in order for the keyword `this` to work in any callbacks.
   - Then we create a [ref](https://reactjs.org/docs/refs-and-the-dom.html#creating-refs) to the inout and checkbox field via `this.inputRef = React.createRef();` and `this.completedRef = React.createRef();`. This is used to get the values from these fields.
     - Note that we also add `ref={this.inputRef}` and `ref={this.inputRef}` to the `input` and `checkbox` respectively.
   - Then we build the `updateTodoItem` method.
     - We immediately update `state` if the `checkbox` is changed via `this.setState({ complete: this.completedRef.current.checked });`. This is because we need to immediately toggle the `TodoItem` depending on whether or not it's complete.
     - We then make a `post` request with the updated `TodoItem` data. Note that it does not update `state`. This is because the data in the `input` field is already up to date, and does not required a refresh. However, if the user were to refresh the page, the new dat would persist.
   - Finally, we create a `handleChange` method that calls the `updateTodoItem` method. This is called via `onChange={this.handleChange}`.

If you [login](http://localhost:3000/users/sign_in) to the application and visit [http://localhost:3000/](http://localhost:3000/) you should see that you're now able to update `TodoItems`.

![creating a todo item](/assets/images/posts/rails-react-tutorial/5.8.gif)

#### Debounce Requests

Although we're able to successfully update `TodoItems`, there is a problem. Every time we type into the `input` field, we make a request to the server. This is problematic because it means our API it being hit very frequently as seen below.

![making a lot of API requests](/assets/images/posts/rails-react-tutorial/5.9.gif)

One way to solve this is to [debounce](https://css-tricks.com/debouncing-throttling-explained-examples/#article-header-id-0) these requests. Rather than roll out our own debounce function, we'll use [Lodash](https://lodash.com/docs/4.17.15#debounce), since heir implementation is battle tested.

> The Debounce technique allow us to "group" multiple sequential calls in a single one.

1. In a new terminal window, run `yarn add lodash`.
2. Open up `app/javascript/packs/components/TodoItem.jsx` and make the following edits.

   <pre data-line="6,12-15,17-30">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoItem.jsx
       import React from "react";
       import PropTypes from "prop-types";
       
       import _ from "lodash";
       import axios from "axios";
       import setAxiosHeaders from "./AxiosHeaders";
       class TodoItem extends React.Component {
         constructor(props) {}
         handleChange() {
           this.setState({
             complete: this.completedRef.current.checked,
           });
           this.updateTodoItem();
         }
         updateTodoItem = _.debounce(() => {
           setAxiosHeaders();
           axios
             .put(this.path, {
               todo_item: {
                 title: this.inputRef.current.value,
                 complete: this.completedRef.current.checked,
               },
             })
             .then((response) => {})
             .catch((error) => {
               console.log(error);
             });
         }, 1000);
       }
     </code>
   </pre>

   - First we move `setState` into the `handleChange` method.
     - This ensures that the `state` is immediately updated when the `onChange` event is fired.
   - Next we update our `updateTodoItem` method to call a `debounce` function which will be invoked 1000 milliseconds (1 second) after it is called.
     - This means that no posts requests will be made to our API until 1 second after a user is done typing or checking/un-checking the checkbox.

   ![debouncing POST requests](/assets/images/posts/rails-react-tutorial/5.10.gif)

### Filtering TodoItems

Now that we can successfully create, update, an delete `TodoItems`, let's add the ability to filter them.

1. Open up `app/javascript/packs/components/TodoItems.jsx` and add the following.

   <pre data-line="4,9,11-13,17-25">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoItems.jsx
       import React from &quot;react&quot;;
       import PropTypes from &quot;prop-types&quot;;
       
       class TodoItems extends React.Component {
         constructor(props) {
           super(props);
           this.handleClick = this.handleClick.bind(this);
         }
         handleClick() {
           this.props.toggleCompletedTodoItems();
         }
         render() {
           return (
             &lt;&gt;
               &lt;hr /&gt;
               &lt;button
                 className=&quot;btn btn-outline-primary btn-block mb-3&quot;
                 onClick={this.handleClick}
               &gt;
                 {this.props.hideCompletedTodoItems
                   ? `Show Completed Items`
                   : `Hide Completed Items `}
               &lt;/button&gt;
             &lt;/&gt;
           );
         }
       }
       export default TodoItems;
       
       TodoItems.propTypes = {
         toggleCompletedTodoItems: PropTypes.func.isRequired,
         hideCompletedTodoItems: PropTypes.bool.isRequired,
       };
     </code>
   </pre>

   - First we import `PropTypes` so that we can handle [typechecking](https://reactjs.org/docs/typechecking-with-proptypes.html), and ensure the `<TodoItems/>` component receives the correct `props`.
     - We declare the what value are required, and their type in the `TodoItems.propTypes` assignment at at the bottom of the file.
   - Then we bind `handleClick` in order for the keyword `this` to work when `onClick` event is fired.
   - Next we create the `handleClick` function which will call `toggleCompletedTodoItems`.
     - Note that this function has not been created yet, but it will update the `state` in `<TodoApp/>`, which can be passed down as `props`.
   - Finally, we add a `<button>` to the component.

2. Next, open `app/javascript/packs/components/TodoItem.jsx` and add the following.

   <pre data-line="9-15,29">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoItem.jsx
         
       class TodoItem extends React.Component {
         constructor(props) {}
         render() {
           const { todoItem } = this.props;
           return (
             &lt;tr
               className={`${
                 this.state.complete &amp;&amp; this.props.hideCompletedTodoItems
                   ? `d-none`
                   : &quot;&quot;
               } ${this.state.complete ? &quot;table-light&quot; : &quot;&quot;}`}
             &gt;
               &lt;td&gt;&lt;/td&gt;
               &lt;td&gt;&lt;/td&gt;
               &lt;td className=&quot;text-right&quot;&gt;&lt;/td&gt;
             &lt;/tr&gt;
           );
         }
       }
       
       export default TodoItem;
       
       TodoItem.propTypes = {
         todoItem: PropTypes.object.isRequired,
         getTodoItems: PropTypes.func.isRequired,
         hideCompletedTodoItems: PropTypes.bool.isRequired,
       };
     </code>
   </pre>

   - We create a [ternary operator](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Conditional_Operator) that will render a class to either show or hide the `<TodoItem/>` depending on whether or not the `hideCompletedTodoItems` and `props` is true or not.
     - Note that this `prop` will be passed down from the `<TodoApp/>` component, which will hold the value of `hideCompletedTodoItems` in `state`.

3. Next, open `app/javascript/packs/components/TodoApp.jsx` and add the following.

   <pre data-line="9, 16-20, 26-27, 34">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoApp.jsx
       
       class TodoApp extends React.Component {
         constructor(props) {
           super(props);
           this.state = {
             todoItems: [],
             hideCompletedTodoItems: false,
           };
           this.getTodoItems = this.getTodoItems.bind(this);
           this.createTodoItem = this.createTodoItem.bind(this);
           this.toggleCompletedTodoItems = this.toggleCompletedTodoItems.bind(this);
         }
       
         toggleCompletedTodoItems() {
           this.setState({
             hideCompletedTodoItems: !this.state.hideCompletedTodoItems,
           });
         }
         render() {
           return (
             <>
               <TodoForm createTodoItem={this.createTodoItem} />
               <TodoItems
                 toggleCompletedTodoItems={this.toggleCompletedTodoItems}
                 hideCompletedTodoItems={this.state.hideCompletedTodoItems}
               >
                 {this.state.todoItems.map((todoItem) => (
                   <TodoItem
                     key={todoItem.id}
                     todoItem={todoItem}
                     getTodoItems={this.getTodoItems}
                     hideCompletedTodoItems={this.state.hideCompletedTodoItems}
                   />
                 ))}
               </TodoItems>
             </>
           );
         }
       }
     </code>
   </pre>

   - First we add `hideCompletedTodoItems` to `state`, and set it to `false` be default.
     - This will allow us to pass the value of `hideCompletedTodoItems` into both the `<TodoItems/>` and `<TodoItem/>` components as `props`. Whenever the `hideCompletedTodoItems` `state` changes, our `<TodoItems/>` and `<TodoItem/>` components will updated accordingly.
   - Next, we bind `toggleCompletedTodoItems` in order for the keyword `this` to work in any callbacks.
   - Then we add `toggleCompletedTodoItems` and `hideCompletedTodoItems` `props` to our `<TodoItems/>` component so it knows what text to display on the button, as well as trigger a `state` change.
   - Finally we add `hideCompletedTodoItems` `props` to our `<TodoItem/>` component so that it knows where or not to hide completed items.

If you [login](http://localhost:3000/users/sign_in) to the application and visit [http://localhost:3000/](http://localhost:3000/) you should see that you're now able to filter `TodoItems`.

![filtering todo items](/assets/images/posts/rails-react-tutorial/5.11.gif)

### Display a Spinner When App is Loading

Right now our application loads very quickly, and it's hard to notice that the screen is ever blank before we pull from our API. However, if there was a network issue, then users might think the application was broken. In order to improve the UI, let's a a loading graphic.

#### Create Spinner Component

First we'll need to create a spinner. Since we're using Bootstrap, we'll just reach for a [spinner](https://getbootstrap.com/docs/4.4/components/spinners/).

1. In a new terminal window, run `touch app/javascript/packs/components/Spinner.jsx` and add the following to the file.

   ```js
   // app/javascript/packs/components/Spinner.jsx
   import React from "react";

   const Spinner = () => {
     return (
       <div className="d-flex align-items-center justify-content-center py-5">
         <div className="spinner-border" role="status">
           <span className="sr-only">Loading...</span>
         </div>
       </div>
     );
   };

   export default Spinner;
   ```

#### Display Spinner

Now that we have a spinner, we need to dynamically have it load.

1. Open `app/javascript/packs/components/TodoApp.jsx` and add the following.

   <pre data-line="4,11,24,27,30,37-38,53-56">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoApp.jsx
       
       import Spinner from "./Spinner";
       class TodoApp extends React.Component {
         constructor(props) {
           super(props);
           this.state = {
             todoItems: [],
             hideCompletedTodoItems: false,
             isLoading: true,
           };
           this.getTodoItems = this.getTodoItems.bind(this);
           this.createTodoItem = this.createTodoItem.bind(this);
           this.toggleCompletedTodoItems = this.toggleCompletedTodoItems.bind(this);
         }
         componentDidMount() {
           this.getTodoItems();
         }
         getTodoItems() {
           axios
             .get("/api/v1/todo_items")
             .then((response) => {
               this.setState({ isLoading: true });
               const todoItems = response.data;
               this.setState({ todoItems });
               this.setState({ isLoading: false });
             })
             .catch((error) => {
               this.setState({ isLoading: true });
               console.log(error);
             });
         }
         render() {
           return (
             <>
               {!this.state.isLoading && (
                 <>
                   <TodoForm createTodoItem={this.createTodoItem} />
                   <TodoItems
                     toggleCompletedTodoItems={this.toggleCompletedTodoItems}
                     hideCompletedTodoItems={this.state.hideCompletedTodoItems}
                   >
                     {this.state.todoItems.map((todoItem) => (
                       <TodoItem
                         key={todoItem.id}
                         todoItem={todoItem}
                         getTodoItems={this.getTodoItems}
                         hideCompletedTodoItems={this.state.hideCompletedTodoItems}
                       />
                     ))}
                   </TodoItems>
                 </>
               )}
               {this.state.isLoading && <Spinner />}
             </>
           );
         }
       }
     </code>
   </pre>

   - First we import our `<Spinner/>` component.
   - Then we add a `isLoading` key to `state`, and set it to `true`.
   - Next we update the `isLoading` `state` in our `getTodoItems` method.
     - As we make a GET request to the API, we set the `isLoading` `state` to `true`. Even though the default `isLoading` `state` is set to `true`, that could change throughout the lifecycle of our application.
     - If we make a successful request to the API, we update the `isLoading` `state` to `false`. If we return an error, we set the `isLoading` `state` to `true`.
   - Finally we wrap our `<TodoForm/>` and `<TodoItems/>` components in a conditional. Unless the `isLoading` `state` is `true`, we load the application. Otherwise we load the `<Spinner/>`.

In order to simulate this, open up your [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi) and update the `isLoading` `state` to `false`.

![spinner while loading](/assets/images/posts/rails-react-tutorial/6.0.gif)

### Displaying Errors

Right now our application only logs errors to the console. In order to improve the UI, let's display helpful error messages.

1. In a new terminal window run `touch app/javascript/packs/components/ErrorMessage.jsx` and add the following to the file.

   ```js
   // app/javascript/packs/components/ErrorMessage.jsx
   import React from "react";

   const ErrorMessage = (props) => {
     return (
       <div className="alert alert-danger" role="alert">
         <p className="mb-0">There was an error.</p>
       </div>
     );
   };

   export default ErrorMessage;
   ```

2. Open up `app/javascript/packs/components/TodoApp.jsx` and add the following.

   <pre data-line="3,11,17-19">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoApp.jsx
       import ErrorMessage from "./ErrorMessage";
       class TodoApp extends React.Component {
         constructor(props) {
           super(props);
           this.state = {
             todoItems: [],
             hideCompletedTodoItems: false,
             isLoading: true,
             errorMessage: null,
           };
         }
         render() {
           return (
             <>
               {this.state.errorMessage && (
                 <ErrorMessage errorMessage={this.state.errorMessage} />
               )}
             </>
           );
         }
       }
     </code>
   </pre>

   - First we import the `<ErrorMessage/>` component.
   - Next we add a `errorMessage` key into `state`, and set the value to `null`.
   - Finally, we display the `<ErrorMessage/>` component if there is a `errorMessage`.

In order to simulate this, open up your [React Developer Tools](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi) and update the `errorMessage` `state` to `true`.

![generic error message](/assets/images/posts/rails-react-tutorial/7.0.gif)

#### When Creating TodoItems

Let's handle errors that occur when a user creates or updates a `TodoItem`.

1. Open up `app/javascript/packs/components/TodoApp.jsx` and add the following.

   <pre data-line="6,7,10-17,28-29">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoApp.jsx
       
       class TodoApp extends React.Component {
         constructor(props) {
           this.handleErrors = this.handleErrors.bind(this);
           this.clearErrors = this.clearErrors.bind(this);
         }
       
         handleErrors(errorMessage) {
           this.setState({ errorMessage });
         }
         clearErrors() {
           this.setState({
             errorMessage: null,
           });
         }
         render() {
           return (
             <>
               {this.state.errorMessage && (
                 <ErrorMessage errorMessage={this.state.errorMessage} />
               )}
               {!this.state.isLoading && (
                 <>
                   <TodoForm
                     createTodoItem={this.createTodoItem}
                     handleErrors={this.handleErrors}
                     clearErrors={this.clearErrors}
                   />
                 </>
               )}
               {this.state.isLoading && <Spinner />}
             </>
           );
         }
       }
     </code>
   </pre>

   - First we bind `handleErrors` and `clearErrors` in order for the keyword `this` to work in any callbacks.
   - Then we create a `handleErrors` method that takes the error message as an argument and use it to update the `errorMessage` `state`.
   - Next we create a `clearErrors` method that sets the `errorMessage` `state` to `null`.
   - Finally we add `handleErrors` and `clearErrors` as props on the `<TodoForm/>` component.

2. Open up `app/javascript/packs/components/TodoForm.jsx` and add the following.

   <pre data-line="18,21,56-57">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoForm.jsx
       
       class TodoForm extends React.Component {
         handleSubmit(e) {
           e.preventDefault();
           setAxiosHeaders();
           axios
             .post(&quot;/api/v1/todo_items&quot;, {
               todo_item: {
                 title: this.titleRef.current.value,
                 complete: false,
               },
             })
             .then((response) =&gt; {
               const todoItem = response.data;
               this.props.createTodoItem(todoItem);
               this.props.clearErrors();
             })
             .catch((error) =&gt; {
               this.props.handleErrors(error);
             });
           e.target.reset();
         }
       
         render() {
           return (
             &lt;form onSubmit={this.handleSubmit} className=&quot;my-3&quot;&gt;
               &lt;div className=&quot;form-row&quot;&gt;
                 &lt;div className=&quot;form-group col-md-8&quot;&gt;
                   &lt;input
                     type=&quot;text&quot;
                     name=&quot;title&quot;
                     ref={this.titleRef}
                     required
                     className=&quot;form-control&quot;
                     id=&quot;title&quot;
                     placeholder=&quot;Write your todo item here...&quot;
                   /&gt;
                 &lt;/div&gt;
                 &lt;div className=&quot;form-group col-md-4&quot;&gt;
                   &lt;button className=&quot;btn btn-outline-success btn-block&quot;&gt;
                     Add To Do Item
                   &lt;/button&gt;
                 &lt;/div&gt;
               &lt;/div&gt;
             &lt;/form&gt;
           );
         }
       }
       
       export default TodoForm;
       
       TodoForm.propTypes = {
         createTodoItem: PropTypes.func.isRequired,
         handleErrors: PropTypes.func.isRequired,
         clearErrors: PropTypes.func.isRequired,
       };
     </code>
   </pre>

   - First we add `this.props.clearErrors();` to the `handleSubmit` method if the POST request was successful. This will remove any errors the were previously displaying.
   - Then we replace the `console.log(error)` with `this.props.handleErrors(error);` in order to display the error message.
   - Finally, we add `handleErrors` and `clearErrors` to our `TodoForm.propTypes` assignment.

3. Next, open up `app/javascript/packs/components/ErrorMessage.jsx` and add the following.

   <pre data-line="4,6,9-22,33-35">
     <code class="language-javascript">
       // app/javascript/packs/components/ErrorMessage.jsx
       import React from &quot;react&quot;;
       import PropTypes from &quot;prop-types&quot;;
       
       import _ from &quot;lodash&quot;;
       
       const ErrorMessage = (props) =&gt; {
         const data = _.get(props.errorMessage, &quot;response.data&quot;, null);
         if (data) {
           const keys = Object.keys(data);
           return keys.map((key) =&gt; {
             return (
               &lt;div key={new Date()} className=&quot;alert alert-danger&quot; role=&quot;alert&quot;&gt;
                 &lt;p&gt;{key}&lt;/p&gt;
                 &lt;ul&gt;
                   &lt;li&gt;{data[key].map((message) =&gt; message)}&lt;/li&gt;
                 &lt;/ul&gt;
               &lt;/div&gt;
             );
           });
         } else {
           return (
             &lt;div className=&quot;alert alert-danger&quot; role=&quot;alert&quot;&gt;
               &lt;p className=&quot;mb-0&quot;&gt;There was an error.&lt;/p&gt;
             &lt;/div&gt;
           );
         }
       };
       
       export default ErrorMessage;
       
       ErrorMessage.propTypes = {
         errorMessage: PropTypes.object.isRequired,
       };
     </code>
   </pre>

   - First we import `PropTypes` so that we can handle [typechecking](https://reactjs.org/docs/typechecking-with-proptypes.html), and ensure the `<ErrorMessage/>` component receives the correct `props`.
   - Then we import `lodash`, so that we can use the [.get()](https://lodash.com/docs/#get) method.
   - Next, we assign `data` to the value of `props.errorMessage.response.data` since Rails will return the error in a `data` Object within a `response` Object.
     - Note that we are using the [.get()](https://lodash.com/docs/#get) method to do this. If this value does not exist, we will return `null`.
   - If there is a `data` Object, we iterate over all the `keys` in the `data` Object and print the `value`.

If you temporarily remove the `required` attribute from the `input` in the `<TodoForm/>` component you can test our code by adding an empty `TodoItem`.

<pre data-line="7">
  <code class="language-javascript">
    // app/javascript/packs/components/TodoForm.jsx
    <input
      type="text"
      name="title"
      ref={this.titleRef}
      // required
      className="form-control"
      id="title"
      placeholder="Write your todo item here..."
    />
  </code>
</pre>

![displaying the error message](/assets/images/posts/rails-react-tutorial/7.1.gif)

Notice that the error message disappears once we successfully add a `TodoItem`. This is because we call `this.props.clearErrors();` in the `handleSubmit` method within the `<TodoForm/>` component upon a successful POST request.

#### When Updating TodoItems

Now let's display errors when updating a `TodoItem`.

1. Open up `/app/javascript/packs/components/TodoApp.jsx` and add the following.

   <pre data-line="27,28">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoApp.jsx
       class TodoApp extends React.Component {
         render() {
           return (
             <>
               {this.state.errorMessage && (
                 <ErrorMessage errorMessage={this.state.errorMessage} />
               )}
               {!this.state.isLoading && (
                 <>
                   <TodoForm
                     createTodoItem={this.createTodoItem}
                     handleErrors={this.handleErrors}
                     clearErrors={this.clearErrors}
                   />
                   <TodoItems
                     toggleCompletedTodoItems={this.toggleCompletedTodoItems}
                     hideCompletedTodoItems={this.state.hideCompletedTodoItems}
                   >
                     {this.state.todoItems.map((todoItem) => (
                       <TodoItem
                         key={todoItem.id}
                         todoItem={todoItem}
                         getTodoItems={this.getTodoItems}
                         hideCompletedTodoItems={this.state.hideCompletedTodoItems}
                         handleErrors={this.handleErrors}
                         clearErrors={this.clearErrors}
                       />
                     ))}
                   </TodoItems>
                 </>
               )}
               {this.state.isLoading && <Spinner />}
             </>
           );
         }
       }
     </code>
   </pre>

   - This will allow our `<TodoItem/>` component pass or clear any error messages in to the `<TodoApp/>` component.

2. Next, open up `app/javascript/packs/components/TodoItem.jsx` and add the following.

   <pre data-line="17,20,32">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoItem.jsx
       
       class TodoItem extends React.Component {
         constructor(props) {}
       
         updateTodoItem = _.debounce(() => {
           setAxiosHeaders();
           axios
             .put(this.path, {
               todo_item: {
                 title: this.inputRef.current.value,
                 complete: this.completedRef.current.checked,
               },
             })
             .then(() => {
               this.props.clearErrors();
             })
             .catch((error) => {
               this.props.handleErrors(error);
             });
         }, 1000);
         render() {}
       }
       
       export default TodoItem;
       
       TodoItem.propTypes = {
         todoItem: PropTypes.object.isRequired,
         getTodoItems: PropTypes.func.isRequired,
         hideCompletedTodoItems: PropTypes.bool.isRequired,
         clearErrors: PropTypes.func.isRequired,
       };
     </code>
   </pre>

   - First we clear any errors by calling `this.props.clearErrors();` after a successful POST request to the API.
   - Then, we display any error messages by calling `this.props.handleErrors(error);` is the POST request returns an error.
   - Finally, we require that the `<TodoItem/>` be passed a `clearErrors` `prop`.

If you remove the text from `TodoItem`, you'll see the error message display.

![errors message when item is blank](/assets/images/posts/rails-react-tutorial/7.2.gif)

Notice that the error message disappears once we successfully add content. This is because we call `this.props.clearErrors();` in the `updateTodoItem` method within the `<TodoItem/>` component upon a successful POST request. Also note that it took 1 second for the message to display. That is because of the `_.debounce` function.

#### When Loading TodoItems

Now all we need to do is display any error messages when we make a GET request to our API.

1. Open up `app/javascript/packs/components/TodoApp.jsx` and add the following.

   <pre data-line="10,18-22">
     <code class="language-javascript">
       // app/javascript/packs/components/TodoApp.jsx
       
       class TodoApp extends React.Component {
         constructor(props) {}
         getTodoItems() {
           axios
             .get("/api/v1/todo_items")
             .then((response) => {
               this.clearErrors();
               this.setState({ isLoading: true });
               const todoItems = response.data;
               this.setState({ todoItems });
               this.setState({ isLoading: false });
             })
             .catch((error) => {
               this.setState({ isLoading: true });
               this.setState({
                 errorMessage: {
                   message: "There was an error loading your todo items...",
                 },
               });
             });
         }
       
         render() {}
       }
     </code>
   </pre>

   - Similar to previous steps, we call `this.clearErrors();` upon a successful GET request to our API.
   - If the GET requests returns an error, we pass a custom error message to the `errorMessage` state.
     - Note that we pass an Object with a `key` of `message` into the `errorMessage` Object. This is because our `<ErrorMessage/>` component expects the `errorMessage` `prop` to be an Object.

2. Open up `app/javascript/packs/components/ErrorMessage.jsx` and add the following.

   <pre data-line="5,7-13">
     <code class="language-javascript">
       // app/javascript/packs/components/ErrorMessage.jsx
       const ErrorMessage = (props) =&gt; {
         const data = _.get(props.errorMessage, "response.data", null);
         const message = _.get(props.errorMessage, "message", null);
         if (data) {
         } else if (message) {
           return (
             &lt;div className="alert alert-danger" role="alert"&gt;
               &lt;p className="mb-0"&gt;{message}&lt;/p&gt;
             &lt;/div&gt;
           );
         } else {
           &lt;div className="alert alert-danger" role="alert"&gt;
             &lt;p className="mb-0"&gt;There was an error.&lt;/p&gt;
           &lt;/div&gt;;
         }
       };
     </code>
   </pre>

   - First, we assign `message` to the value of `props.errorMessage.message`.
     - Note that we are using the [.get()](https://lodash.com/docs/#get) method to do this. If this value does not exist, we will return `null`.
   - Then we add an `else if` conditional and render the message.

If you temporarily break the GET request in the `getTodoItems` method in the `<TodoApp/>` component, you will see the error display.

<pre data-line="11">
  <code class="language-javascript">
    // app/javascript/packs/components/TodoApp.jsx
    
    class TodoApp extends React.Component {
      constructor(props) {}
      componentDidMount() {
        this.getTodoItems();
      }
      getTodoItems() {
        axios
          .get("/broken-end-point")
          .then((response) => {})
          .catch((error) => {});
      }
    
      render() {}
    }
  </code>
</pre>

![error state](/assets/images/posts/rails-react-tutorial/7.3.png)

## Conclusion and Next Steps

As you can see, there's a lot to consider when building a full-stack web application. However, by learning how to build an API, you have complete control of your data, and avoid vendor lock-in with services like Firebase.

If you decide to deploy with [Heroku](https://www.heroku.com/home), you'll want to use the **nodejs** and **ruby** [buildpacks](https://elements.heroku.com/buildpacks)

![nodejs and ruby buildbacks](/assets/images/posts/rails-react-tutorial/8.0.png)

Finally, you'll want to write tests for your application. Writing tests was beyond the scope of this tutorial, but you can see [the tests I wrote](https://github.com/stevepolitodesign/rails-react-example/tree/master/spec), or clone the [repo](https://github.com/stevepolitodesign/rails-react-example) and run the tests locally.
