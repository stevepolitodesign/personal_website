---
title: "Use Pundit as a Rails Feature Flag System"
date: "2021-06-21"
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/pundit-feature-flags",
    },
  ]
og_image: https://mugshotbot.com/m/rrwkolZP
---

In this tutorial, I'll show you how to create a feature flag system in Rails using [pundit](https://github.com/varvet/pundit) and a `features` column on the `users` table.

## Step 1: Initial Setup

This tutorial assumes you are using [devise](https://github.com/heartcombo/devise) and have a `User` model. However, you should still be able to follow along and implement this pattern even if that's not the case.

1. Create a `Post` scaffold.

   ```sh
   rails g scaffold Post title:string user:references meta_description:text
   ```

````

2. Add a `features` column to the `users` table by running the following command.

    ```sh
    rails g migration add_features_to_users features:jsonb
    ```

3. Set a default value on the `features` column.

    ```ruby
    class AddFeaturesToUsers < ActiveRecord::Migration[6.1]
      def change
        add_column :users, :features, :jsonb, default: {}
      end
    end
    ```

    > **What's Going On Here?**
    >
    > - We add a [JSONB Column](https://guides.rubyonrails.org/active_record_postgresql.html#json-and-jsonb) to our `users` table. This will allow us to store multiple features in one column, compared to making a column for each feature.
    > - We add `default: {}` simply to add a formatted default value to this column.

4. Run the migrations.

    ```sh
    rails db:migrate
    ```

5. Set features on `User` model.

    ```ruby
    class User < ApplicationRecord
      FEATURES = %i[enable_post_meta_description].freeze
      store :features, accessors: User::FEATURES
    end
    ```

    > **What's Going On Here?**
    >
    > - We create a `FEATURES` constant that will store the names of our features as symbols by calling `%i` on the array. We call `.freeze` to ensure this constant cannot be updated anywhere else.
    > - We use [ActiveRecord::Store](https://api.rubyonrails.org/classes/ActiveRecord/Store.html) to interface with the `features` column. This will allow us to call `@user.enable_post_meta_description` instead of `user.features.enable_post_meta_description`. By passing `User::FEATURES` into the `accessors` parameter we can continue to add new features in the `FEATURES` constant.

    Setting a `features` column on the `users` table will allow us to enable/disable features on a per-user basis.

6. Enable the `enable_post_meta_description` for a user. That way you have something to test.

    ```ruby
    User.last.update(enable_post_meta_description: true)
    ```

## Step 2: Install Pundit and Build a Policy

Next, we'll need to install and configure [pundit](https://github.com/varvet/pundit).

1. Install [pundit](https://github.com/varvet/pundit).

    ```sh
    bundle add pundit
    ```

2. Generate the base pundit files.

    ```sh
    rails g pundit:install
    ```

3. Include pundit in the `ApplicationController`

    ```ruby
    class ApplicationController < ActionController::Base
      include Pundit
    end
    ```

## Step 3: Build a Feature Flag Policy

1. Generate a namespaced pundit policy.

    ```sh
    rails g pundit:policy feature/enable_post_meta_description
    ```

2. Build the policy

    ```ruby
    class Feature::EnablePostMetaDescriptionPolicy < ApplicationPolicy
      def ceate?
        user.present? && (user.enable_post_meta_description == true)
      end

      def permitted_attributes
        if user.enable_post_meta_description == true
          %i[title user_id meta_description]
        else
          %i[title user_id]
        end
      end
    end
    ```

> **What's Going On Here?**
>
> - We generate a policy under the `feature` namespace. This is not required, but it helps keep things organized and will allow us to add new policies for new features later. We also name this policy to match the name of the feature in the `User` model.
> - We build a `ceate?` method that returns `true` or `false` based on whether or not that user has the `enable_post_meta_description` feature set to true. We could have called the method `index?`, `new?`, `update?`, `edit?` or `destroy?` but `create?` makes the most sense in this context. We're building a policy that enables a user to **create** a meta description on a post.
> - We used pundit's [permitted_attributes](https://github.com/varvet/pundit#strong-parameters) method to return an array of paramters to be used in the `PostsController`. This will allow us to conditionally permit the `meta_description` parameter.

## Step 4: Implement the Feature Flag

1. Update the `post_params` to hook into the `permitted_attributes` method.

    ```ruby
    class PostsController < ApplicationController
      before_action :authenticate_user!, except: %i[show index]
      before_action :set_post, only: %i[show edit update destroy]

      private

      def post_params
        params.require(:post).permit(
          Feature::EnablePostMetaDescriptionPolicy.new(
            current_user,
            Post,
          ).permitted_attributes,
        )
      end
    end
    ```

    > **What's Going On Here?**
    >
    > - We instantiate a new instance of the `Feature::EnablePostMetaDescriptionPolicy` policy class and pass in the `current_user` and `Post` per pundit's API. Then we call `permitted_attributes` to load the correct parameters based on whether the user has access to the `meta_description`.
    > - Note that we call `authenticate_user!` before all actions except `show` and `index` since the `Feature::EnablePostMetaDescriptionPolicy` relies on a user.

2. Conditionally show the `meta_description` in the post form partial.

    ```erb
    # app/views/posts/_form.html.erb
    <%= form_with(model: post) do |form| %>
      <% if Feature::EnablePostMetaDescriptionPolicy.new(current_user, post).create? %>
        <div class="field">
          <%= form.label :meta_description %>
          <%= form.text_area :meta_description %>
        </div>
      <% end %>
    <% end %>
    ```

> **What's Going On Here?**
>
> - We wrap the `meta_description` field in a new instance of the `Feature::EnablePostMetaDescriptionPolicy` policy class. We call `create?` which returns `true` or `false` based on whether the user has access to the `meta_description`.
````
