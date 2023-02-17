---
title: "PaperTrail Gem Tutorial"
excerpt:
  In this tutorial I am going to show you how to revert and restore records using
  the PaperTrail Gem.
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/paper-trail-gem-tutorial",
    },
    {
      title: "PaperTrail Gem",
      url: "https://github.com/paper-trail-gem/paper_trail",
    },
  ]
date: 2020-04-20
---

## Introduction

In this tutorial I am going to show you how to revert and restore records using the [PaperTrail Gem](https://github.com/paper-trail-gem/paper_trail).

### Reverting Old Versions

![reverting old versions](/assets/images/posts/paper-trail-gem-tutorial/revert_article.gif)

### Restoring Deleted Versions

![restoring old versions](/assets/images/posts/paper-trail-gem-tutorial/restore_article.gif)

## Step 1: Setup

### Generate Base Application

First we need to create a base application on which to build. Open up a terminal window and run the following commands.

```text
rails new paper-trail-gem-tutorial -d=postgresql
cd paper-trail-gem-tutorial
rails db:create
rails g scaffold Article title body:text
rails db:migrate
```

### Install and Configure PaperTrail

Next we need to install the [paper_trail Gem](https://rubygems.org/gems/paper_trail). Open up your application's `Gemfile` and add the following.

```ruby
# Gemfile

gem "paper_trail", "~> 10.3", ">= 10.3.1"
```

Next, run the following commands from your application's root per the [installation instructions](https://github.com/paper-trail-gem/paper_trail/blob/v10.3.1/README.md#1b-installation).

```sh
bundle install
bundle exec rails generate paper_trail:install
bundle exec rake db:migrate
```

Next, add `has_paper_trail` to the **Article** model.

```ruby
# app/models/article.rb

class Article < ApplicationRecord
  has_paper_trail
end
```

### Add Seed Data

In order to have something to work with, we'll want to add some [seed data](https://guides.rubyonrails.org/active_record_migrations.html#migrations-and-seed-data) to our application.

> **faker** is a library for generating fake data such as names, addresses, and phone numbers.

Add the [faker Gem](https://rubygems.org/gems/faker) to your application's `Gemfile` and run `bundle install`.

```ruby
# Gemfile

gem "paper_trail", "~> 10.3", ">= 10.3.1"
gem "faker", "~> 2.11"
```

Next, add the following to `db/seeds.rb`.

```ruby
# db/seeds.rb

@article = Article.create(title: "Version 1", body: Faker::Lorem.paragraph)
2.upto(6) { |i| @article = Article.update(title: "Version #{i}") }

1.upto(2) do |i|
  @deleted_article =
    Article.create(
      title: "Deleted Article #{i} Version 1",
      body: Faker::Lorem.paragraph,
    )
  @deleted_article.destroy
  @deleted_article = Article.new(id: @deleted_article.id).versions.last.reify
  @deleted_article.save
  @deleted_article.update(title: "Deleted Article #{i} Version 2")
  @deleted_article.destroy
end

@restored_article =
  Article.create(
    title: "A Previously Deleted Article",
    body: Faker::Lorem.paragraph,
  )
@restored_article.destroy
@restored_article = Article.new(id: @restored_article.id).versions.last.reify
@restored_article.save
```

Finally, run `rails db:seed`.

### Update Root Path

Now we just need to update our `routes` so that the `root_path` displays our data.

Open up `config/routes.rb` and add the following:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # ℹ️ Add this route
  root to: "articles#index"
  resources :articles
end
```

Finally, run `rails s` in your application's root directory and navigate to `http://localhost:3000/`. You should see something similar to the following:

![homepage displaying articles](/assets/images/posts/paper-trail-gem-tutorial/1.1.png)

## Step 2: Display Previous Versions

Now that we have a basic application with seed data, we can start to carve out our versioning system. The first step is to create a [partial](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials) to be shared across layouts.

### Create a Partial

First create a new [partial](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials) by running `touch app/views/articles/_article.html.erb` in your application's root. Then, add the following:

```erb
<!-- app/views/articles/_article.html.erb -->
<tr>
  <td><%= article.title %></td>
  <td><%= article.body %></td>
  <td><%= link_to 'Show', article_path(article) %></td>
  <td><%= link_to 'Edit', edit_article_path(article) %></td>
  <td><%= link_to 'Destroy', article_path(article), method: :delete, data: { confirm: 'Are you sure?' } %></td>
</tr>
```

Then, replace everything within `<tbody></tbody>` with `<%= render @articles %>` in `app/views/articles/index.html.erb`.

```erb
<!-- app/views/articles/index.html.erb -->
<p id="notice"><%= notice %></p>

<h1>Articles</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Body</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% # ℹ️ Render the article partial %>
    <%= render @articles %>
  </tbody>
</table>

<br>

<%= link_to 'New Article', new_article_path %>
```

### Create a Versions Action

Next, open `app/controllers/articles_controller.rb` and add the following:

```ruby
# app/controllers/articles_controller.rb

class ArticlesController < ApplicationController
  # ℹ️ Add a before_action
  before_action :set_article, only: %i[show edit update destroy versions]
  # ℹ️ Add new controller action
  def versions
    @articles = @article.versions
  end
end
```

- We add `:versions` to the `before_action :set_article` so that our `versions` action has access to the `@article` stored in the private `set_article` method.
- The `.versions` method is provided by [paper_trail](https://github.com/paper-trail-gem/paper_trail#1d-api-summary), and returns all versions of a given record.

### Create a Versions Route

Next, open up `config/routes.rb` and add the following:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root to: "articles#index"
  resources :articles do
    # ℹ️ Add route to versions action
    member { get "versions", to: "articles#versions" }
  end
end
```

- We use a [member](https://guides.rubyonrails.org/routing.html#adding-member-routes) route in order to organize our route based on the associated **Article**.

### Create a Versions View

Next, we'll need to create a corresponding view to display all **Article** versions. In the root of your application, run `cp app/views/articles/index.html.erb app/views/articles/versions.html.erb`

Next, open `app/views/articles/versions.html.erb` and add the following:

```erb
<!-- app/views/articles/versions.html.erb -->
<p id="notice"><%= notice %></p>

<h1>Previous Versions</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Body</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <%= render partial: "article", collection: @articles %>
  </tbody>
</table>

<br>

<%= link_to 'Back', articles_path %>
```

- We update the title.
- We add `<%= render partial: "article", collection: @articles %>` which will render the `app/views/articles/_article.html.erb` partial, and use the `@articles` instance variable from the `versions` action.

### Refactor Article Partial

If you navigate to the new route, such as `http://localhost:3000/articles/1/versions`, you will see the following error:

![undefined method `title' for #<PaperTrail::Version:0x00007f81a84c9fd8>](/assets/images/posts/paper-trail-gem-tutorial/2.1.png)

This is because the `versions` action is returning `PaperTrail::Version` instances, not `Article` instances.

#### Load Correct Version Data

In order to fix the error add the following to `app/views/articles/_article.html.erb`.

```erb
<%# app/views/articles/_article.html.erb %>
<%# ℹ️ Only load these links if we are working on an existing article %>
<% unless article.try(:event) && article.event == "create" %>
  <tr>
    <%# ℹ️ Conditionally load the title for the previous version %>
    <td><%= article.try(:reify) ? article.reify.title : article.title %></td>
    <%# ℹ️ Conditionally load the body for the previous version %>
    <td><%= article.try(:reify)  ? article.reify.body : article.body %></td>
    <td><%= link_to 'Show', article_path(article) %></td>
    <td><%= link_to 'Edit', edit_article_path(article) %></td>
    <td><%= link_to 'Destroy', article_path(article), method: :delete, data: { confirm: 'Are you sure?' } %></td>
  </tr>
<% end %>
```

> PaperTrail does not waste space storing a version of the object as it currently stands

- We wrap our partial in a conditional that checks to see if the current version is simply the creation of the record by checking the [event](https://github.com/paper-trail-gem/paper_trail#the-versionsevent-column) value.
  - Note that we we also run `article.try(:event)` incase the record being passed into the partial is not a `PaperTrail::Version` instance.
- We conditionally load the `title` and `body` using a call to [reify](https://github.com/paper-trail-gem/paper_trail/blob/2cdfb525d070c1f8cb1ba389cfcd1c14957731dc/lib/paper_trail/reifier.rb#L12). Reify simply deserializes the value stored in the `object` column on a `PaperTrail::Version` instance. This value is a serialized version of the **Article**.
  - Note that we we also run `article.try` incase the record being passed into the partial is not a `PaperTrail::Version` instance.

This seems to have fixed the problem. However, if you visit the `versions` path for an `article` you will see any `version` where the action was `destroy`. For example, if you visit `http://localhost:3000/articles/4/versions` you should see the following:

![a deleted version appearing in the version history](/assets/images/posts/paper-trail-gem-tutorial/2.2.png)

Open up `app/views/articles/_article.html.erb` and make the following edit:

```erb
<%# app/views/articles/_article.html.erb %>
<%# ℹ️ Only load these links if we are editing existing article %>
<% unless article.try(:event) && (article.event == "create" || article.event == "destroy") %>
  <tr>
   ...
  </tr>
<% end %>
```

- We add `article.event == "destroy"` to hide any version where the `event` was `destroy`.

Now if you visit `http://localhost:3000/articles/4/versions` you'll no longer see that `deleted` version.

#### Add Versions Link to Partial

Finally, let's add a link to the versions page for each **Article**. Open up `app/views/articles/_article.html.erb` and make the following edit:

```erb
<!-- app/views/articles/_article.html.erb -->

<% unless article.try(:event) && article.event == "create" %>

  <tr>
    <td><%= article.try(:reify) ? article.reify.title : article.title %></td>
    <td><%= article.try(:reify)  ? article.reify.body : article.body %></td>
    <%# ℹ️ Only load these links on the index page %>
    <% if params[:action] == "index" %>
      <td><%= link_to 'Show', article_path(article) %></td>
      <td><%= link_to 'Edit', edit_article_path(article) %></td>
      <%# ℹ️ Add a link to the versions page %>
      <td><%= link_to 'Versions', versions_article_path(article) %></td>
      <td><%= link_to 'Destroy', article_path(article), method: :delete, data: { confirm: 'Are you sure?' } %></td>
    <% end %>
  </tr>
<% end %>
```

- We wrap our links in a conditional so that they only appear when viewed on the `index` view.

If you navigate to `http://localhost:3000/articles/1/versions` you should see the following:

![previous versions](/assets/images/posts/paper-trail-gem-tutorial/2.3.png)

## Step 3: Preview Previous Versions

Now that we have a page which lists all previous versions, we'll want to add a page to preview that version.

### Create a Version Action

Open up `app/controllers/articles_controller.rb` and add the following:

```ruby
# app/controllers/articles_controller.rb

class ArticlesController < ApplicationController
  # ℹ️ Load the article on the version action
  before_action :set_article,
                only: %i[show edit update destroy versions version]
  # ℹ️ Load the version on the version action
  before_action :set_version, only: [:version]

  def version
  end

  private

  # ℹ️ Find the version based on the params
  def set_version
    @version =
      PaperTrail::Version.find_by(item_id: @article, id: params[:version_id])
  end
end
```

- We create a private `set_version` method that finds a particular version of an **Article**.
- The `PaperTrail::Version` instance can be [queried](https://guides.rubyonrails.org/active_record_querying.html#retrieving-objects-from-the-database) just like any other record.
  - Here, we're looking for an instance of `PaperTrail::Version` where the `item_id` is the same as the `id` of current `@article`, and the `id` is set from `params[:version_id]`.

### Create a Version Route

Next, open up `config/routes.rb` and add the following:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root to: "articles#index"
  resources :articles do
    member do
      get "versions", to: "articles#versions"
      # ℹ️ Add a route for the version action
      get "version/:version_id", to: "articles#version", as: "version"
    end
  end
end
```

### Create a Version View

Finally, create a new view by running `cp app/views/articles/show.html.erb app/views/articles/version.html.erb` in the applications root.

Open up `app/views/articles/version.html.erb` and make the following edits:

```erb
<!-- app/views/articles/version.html.erb -->
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%# ℹ️ Load the title for the specific version %>
  <%= @version.reify.title %>
</p>

<p>
  <strong>Body:</strong>
  <%# ℹ️ Load the body for the specific version %>
  <%= @version.reify.body %>
</p>

<%# ℹ️  Link back to the other versions %>
<%= link_to 'Back', versions_article_path(@article) %>

```

- We call `reify` in order to deserialize the value stored in the `@version.object` column.
- We add a back button for improved user experience.

### Refactor Article Partial

Now that we have a view to render a preview, we can add a link allowing a user to view that specific version.

Open up `app/views/articles/_article.html.erb` and add the following:

```erb
<!-- app/views/articles/_article.html.erb -->

<% unless article.try(:event) && article.event == "create" %>

  <tr>
    <td><%= article.try(:reify) ? article.reify.title : article.title %></td>
    <td><%= article.try(:reify)  ? article.reify.body : article.body %></td>
    <% if params[:action] == "index" %>
      <td><%= link_to 'Show', article_path(article) %></td>
      <td><%= link_to 'Edit', edit_article_path(article) %></td>
      <td><%= link_to 'Versions', versions_article_path(article) %></td>
      <td><%= link_to 'Destroy', article_path(article), method: :delete, data: { confirm: 'Are you sure?' } %></td>
    <% end %>
    <%# ℹ️ Link to the version only if we're viewing a list of versions %>
    <% if params[:action] == "versions" %>
        <td><%= link_to 'Preview This Version', version_article_path(@article, article) %></td>
    <% end %>
  </tr>
<% end %>
```

- Note the we conditionally load this link to only appear on the `versions` view.

If you navigate to `http://localhost:3000/articles/1/versions` you should see the following:

![preview this version links](/assets/images/posts/paper-trail-gem-tutorial/3.1.png)

If you navigate to a specific version, like `http://localhost:3000/articles/1/version/2`, you should see a preview of that version.

![version show page](/assets/images/posts/paper-trail-gem-tutorial/3.2.png)

## Step 4: Revert Previous Versions

Now that we can view previous versions, we need the ability to revert back to them.

### Create Revert Action

Open up `app/controllers/articles_controller.rb` and add the following:

```ruby
# app/controllers/articles_controller.rb

class ArticlesController < ApplicationController
  # ℹ️ Add the revert action to both before actions
  before_action :set_article,
                only: %i[show edit update destroy versions version revert]
  before_action :set_version, only: %i[version revert]

  # ℹ️ Add a revert action
  def revert
    @reverted_article = @version.reify
    if @reverted_article.save
      redirect_to @article, notice: "Article was successfully reverted."
    else
      render version
    end
  end

  private
end
```

- We add `:revert` to `before_action :set_article` and `before_action :set_version` in order to have access to the specific `@article` and `@version`.
- We call `reify` on the `@version` in order to deserialize the data stored in the `object` column.

### Create Revert Route

Next we need to create a route to correspond with this action. Open up `config/routes.rb` and add the following:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root to: "articles#index"
  resources :articles do
    member do
      get "versions", to: "articles#versions"
      get "version/:version_id", to: "articles#version", as: "version"
      # ℹ️ Add a route to the revert action
      post "revert/:version_id", to: "articles#revert", as: "revert"
    end
  end
end
```

- Note that we issue a `post` request, since we're writing to the database.

### Refactor Version Partial

Now that we have an action and corresponding route, we need the ability to revert via a link. Open up `app/views/articles/version.html.erb` and add the following:

```erb
<!-- app/views/articles/version.html.erb -->
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @version.reify.title %>
</p>

<p>
  <strong>Body:</strong>
  <%= @version.reify.body %>
</p>

<%# ℹ️ Add a link to revert to this version %>
<%= link_to 'Revert to this version', revert_article_path(@article, @version), method: :post %>
<%= link_to 'Back', versions_article_path(@article) %>
```

- Note that we add `method: :post` to issue a `post` request.

If you navigate to `http://localhost:3000/articles/1/version/2` for should now be able to revert to older versions.

![reverting to previous version](/assets/images/posts/paper-trail-gem-tutorial/4.2.gif)

## Step 5: Display Deleted Versions

Now let's add the ability to view deleted versions.

### Create Deleted Action

Open up `app/controllers/articles_controller.rb` and add the following:

```ruby
# app/controllers/articles_controller.rb

class ArticlesController < ApplicationController
  # ℹ️ Add a deleted action to load any articles that were deleted
  def deleted
    @articles =
      PaperTrail::Version.where(item_type: "Article", event: "destroy").order(
        created_at: :desc,
      )
  end

  private
end
```

- Here we simply query for all instances of `PaperTrail::Version` where the `item_type` is **Article** and the `event` was **destroy**. Simply put, this finds all versions of deleted **Articles**.
- We `order` the query by `created_at: :desc`, in order to view the most recently deleted **Articles** first.

### Create Deleted Route

Next we need to add a corresponding route for our `deleted` action. Open up `config/routes.rb` and add the following:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root to: "articles#index"
  resources :articles do
    member do
      get "versions", to: "articles#versions"
      get "version/:version_id", to: "articles#version", as: "version"
      post "revert/:version_id", to: "articles#revert", as: "revert"
    end
    # ℹ️ Add a route to the new deleted action
    collection { get "deleted", to: "articles#deleted" }
  end
end
```

- We use a [collection](https://guides.rubyonrails.org/routing.html#adding-collection-routes) route in order for the path to be `articles/deleted`.

### Create Deleted View

Now we need a view to display deleted **Articles**. In the root of your application run `cp app/views/articles/versions.html.erb app/views/articles/deleted.html.erb`

Now, open up `app/views/articles/deleted.html.erb` and add the following:

```erb
<!-- app/views/articles/deleted.html.erb -->
<p id="notice"><%= notice %></p>

<h1>Deleted Articles</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Body</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <%= render partial: "article", collection: @articles %>
  </tbody>
</table>

<br>

<%= link_to 'Back', articles_path %>
```

- Note that all we change is the page tilte.

### Refactor Deleted Action

If you navigate to `http://localhost:3000/articles/deleted` you should see the following:

![a page listing every version where the action was deleted](/assets/images/posts/paper-trail-gem-tutorial/5.1.png)

What's happening is that we're seeing **ALL** versions of deleted **Articles**. For example, an **Article** can be destroyed, and then restored, and then destroyed again many times. This means that there are can be multiple instances of versions where the `event` is set to `destroy` for a single **Article**.

To account for this, we need to refactor our `deleted` action. Open up `app/controllers/articles_controller.rb` and update the following:

```ruby
# app/controllers/articles_controller.rb

class ArticlesController < ApplicationController
  def deleted
    # ℹ️ Get all deleted versions
    @destroyed_versions =
      PaperTrail::Version.where(item_type: "Article", event: "destroy").order(
        created_at: :desc,
      )
    # ℹ️ Get the latest destroyed version of each article
    @latest_destroyed_versions =
      @destroyed_versions
        .filter { |v| v.reify.versions.last.event == "destroy" }
        .map(&:reify)
        .uniq(&:id)
    @articles = @latest_destroyed_versions
  end

  private
end
```

#### Understanding the Query

Admittedly this refactor is a little cryptic, so let's go through it in smaller pieces.

> Our end goal is to get the latest deleted version of an **Article**, and ignore older deleted versions of the same **Article**.

Open up the rails console and by running `rails c -s`

##### PaperTrail::Version.where(item_type: "Article", event: "destroy")

```bash
> PaperTrail::Version.where(item_type: "Article", event: "destroy").order(created_at: :desc).count
>
> => 5
```

- Here we simply query for all instances of `PaperTrail::Version` where the `item_type` is **Article** and the `event` was **destroy**. Simply put, this finds all versions of deleted **Articles**.

##### .filter { |v| v.reify.versions.last.event == "destroy" }

```bash
> PaperTrail::Version.where(item_type: "Article", event: "destroy").order(created_at: :desc).filter { |v| v.reify.versions.last.event == "destroy" }.count
>
> => 4
```

- Building off of that query, we can call [filter](https://ruby-doc.org/core-2.7.1/Array.html#method-i-filter) to only return **Articles** where the last version was destroy. This is important because we don't need to see all previous version of the **Article** when the `event` was destroy.
- This goes back to the idea that an **Article** can be destroyed, and then restored multiple times. If an **Article** was destroyed, and then restored, we no longer need to see the version of the **Article** when is was destroyed.

##### .map(&:reify)

```bash
> PaperTrail::Version.where(item_type: "Article", event: "destroy").order(created_at: :desc).filter { |v| v.reify.versions.last.event == "destroy" }.map(&:reify)
>
> => [#<Article id: 3, title: "Deleted Article 2 Version 2", body: "Est aut ex. Ea sit ipsam. Tempora dolorem fuga.", created_at: "2020-04-20 14:34:39", updated_at: "2020-04-20 14:34:39">, #<Article id: 3, title: "Deleted Article 2 Version 1", body: "Est aut ex. Ea sit ipsam. Tempora dolorem fuga.", created_at: "2020-04-20 14:34:39", updated_at: "2020-04-20 14:34:39">, #<Article id: 2, title: "Deleted Article 1 Version 2", body: "Quaerat praesentium sint. Repudiandae explicabo no", created_at: "2020-04-20 14:34:39", updated_at: "2020-04-20 14:34:39">, #<Article id: 2, title: "Deleted Article 1 Version 1", body: "Quaerat praesentium sint. Repudiandae explicabo no", created_at: "2020-04-20 14:34:39", updated_at: "2020-04-20 14:34:39">]
```

- By addng a call to [map](https://ruby-doc.org/core-2.7.1/Array.html#method-i-map), we can return an array of `Article` instances, and not `PaperTrail::Version` instances.
- This will allow us to have access to columns on the `Article` class.

##### .uniq(&:id)

```bash
> PaperTrail::Version.where(item_type: "Article", event: "destroy").order(created_at: :desc).filter { |v| v.reify.versions.last.event == "destroy" }.map(&:reify).uniq(&:id)
>
> => [#<Article id: 3, title: "Deleted Article 2 Version 2", body: "Est aut ex. Ea sit ipsam. Tempora dolorem fuga.", created_at: "2020-04-20 14:34:39", updated_at: "2020-04-20 14:34:39">, #<Article id: 2, title: "Deleted Article 1 Version 2", body: "Quaerat praesentium sint. Repudiandae explicabo no", created_at: "2020-04-20 14:34:39", updated_at: "2020-04-20 14:34:39">]
```

- Finally, we can add a call to [uniq](https://ruby-doc.org/core-2.7.1/Array.html#method-i-uniq) to eliminate duplicates from the array of `Article` instances based on the `id` column.
- It's important that we called `.order(created_at: :desc)` on the query. Otherwise the new array of `Article` instances would be older deleted versions.

Now if you navigate to `http://localhost:3000/articles/deleted`, you should see a filtered list.

![only the most recently deleted versions appear](/assets/images/posts/paper-trail-gem-tutorial/5.2.png)

## Step 6: Restore Deleted Versions

Now that the heavy lifting is done, we can easily restore a deleted **Article**.

### Create Restore Action

Open up `app/controllers/articles_controller.rb` and add the following:

```ruby
# app/controllers/articles_controller.rb

class ArticlesController < ApplicationController
  def restore
    # ℹ️ Get the last version of the article
    @latest_version = Article.new(id: params[:id]).versions.last
    # ℹ️ Restore the last version if it was destroyed
    if @latest_version.event == "destroy"
      @article = @latest_version.reify
      if @article.save
        redirect_to @article, notice: "Article was successfully restored."
      else
        render "deleted"
      end
    end
  end

  private
end
```

- We make sure to see if the latest version was triggered by a `destroy` `event`. This is important because we don't want to restore a version that is actually no longer destroyed.

### Create Restore Route

Next, we need to add a corresponding route for our `restore` action. Open up `config/routes.rb` and add the following:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root to: "articles#index"
  resources :articles do
    member do
      get "versions", to: "articles#versions"
      get "version/:version_id", to: "articles#version", as: "version"
      post "revert/:version_id", to: "articles#revert", as: "revert"
      # ℹ️ Add a route to the restore action
      post "restore", to: "articles#restore", as: "restore"
    end
    collection { get "deleted", to: "articles#deleted" }
  end
end
```

- Note that we issue a `post` request, since we're writing to the database.

### Refactor Article Partial

Now that we have an action and corresponding route, we need the ability to restore via a link. Open up `app/views/articles/version.html.erb` and add the following:

```erb
<!-- app/views/articles/_article.html.erb -->

<% unless article.try(:event) && article.event == "create" %>

  <tr>
    <td><%= article.try(:reify) ? article.reify.title : article.title %></td>
    <td><%= article.try(:reify)  ? article.reify.body : article.body %></td>
    <% if params[:action] == "index" %>
      <td><%= link_to 'Show', article_path(article) %></td>
      <td><%= link_to 'Edit', edit_article_path(article) %></td>
      <td><%= link_to 'Versions', versions_article_path(article) %></td>
      <td><%= link_to 'Destroy', article_path(article), method: :delete, data: { confirm: 'Are you sure?' } %></td>
    <% end %>
    <% if params[:action] == "versions" %>
        <td><%= link_to 'Preview This Version', version_article_path(@article, article) %></td>
    <% end %>
    <%# ℹ️ Load a link to restore the article if viewed from the deleted index %>
    <% if params[:action] == "deleted" %>
        <td><%= link_to 'Restore This Article', restore_article_path(article), method: :post %></td>
    <% end %>
  </tr>
<% end %>
```

- Note the we conditionally load this link to only appear on the `deleted` view.

If you navigate to `http://localhost:3000/articles/deleted` you should be able to restore a deleted **Article**.

![restoring a deleted article](/assets/images/posts/paper-trail-gem-tutorial/6.2.gif)

## Conclusion and Next Steps

The PaperTrail Gem is powerful in it's simplicity. By storing all events and their associated record in a separate `versions` table, one can create an auditing version as simple or as complex as needed. This tutorial just explored common patterns. Don't feel you need to follow them precisely.

As always, make sure to thoroughly test your application. You can view this application's [controller](https://github.com/stevepolitodesign/paper-trail-gem-tutorial/blob/master/test/controllers/articles_controller_test.rb) and [integration](https://github.com/stevepolitodesign/paper-trail-gem-tutorial/blob/master/test/integration/version_flow_test.rb) tests for inspiration.
