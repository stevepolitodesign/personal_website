---
title: "Rails Server Side Analytics From Scratch"
excerpt: "
  Learn how to track user events without sacrificing privacy and performance.
  "
categories: ["Ruby on Rails"]
tags: ["Analytics"]
canonical_url: https://thoughtbot.com/blog/rails-server-side-analytics-from-scratch
---

In this tutorial, we'll learn how to create server-side analytics from scratch using Ruby on Rails. If at any point you wish to explore on your own, simply clone or fork the [example repository](https://github.com/thoughtbot/rails-server-side-analytics) on which this post is based.

## Benefits and Risks

It's important to understand the benefits and risks before implementing your own server-side analytics. Below are a few examples of each.

This tutorial will address all privacy related risks.

### Benefits

- Better performance when compared to client-side tracking via JavaScript.
- Can't be blocked by an [ad blocker](https://ublockorigin.com/).
- You have complete control and ownership of your data, and are not giving it to a third party.
- The code can abstracted into a gem, and reused across multiple applications.

### Risks

- You are responsible for keeping your user's data secure.
- How long should you keep your user's data?
- What happens to a user's data if they cancel their account?
- Should you be tracking a user without their consent?

## Create visitor and track their events

### Create visitor and event models

```ruby
# db/migrate/[timestamp]_create_visitors.rb
class CreateVisitors < ActiveRecord::Migration[7.0]
  def change
    create_table :visitors do |t|
      t.string :user_agent

      t.timestamps
    end
  end
end
```

The `user_agent` column will store data about the user's device and browser. This value will be returned from the [request object](https://api.rubyonrails.org/v7.0.2.2/classes/ActionDispatch/Request.html).

```ruby
# db/migrate/[timestamp]_create_events.rb
class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :path, null: false
      t.string :method, null: false
      t.string :params
      t.references :visitor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

The `path` column will store the relative path that was requested, while the `method` column will store the type of request made. This will help us determine if someone visited a page as opposed to filled out a form. Finally, the `params` column will store the value of any [query_parameters](https://api.rubyonrails.org/v7.0.2.2/classes/ActionDispatch/Request.html#method-i-query_parameters) or [request_parameters](https://api.rubyonrails.org/v7.0.2.2/classes/ActionDispatch/Request.html#method-i-request_parameters) Again, all of these values will be returned from the [request object](https://api.rubyonrails.org/v7.0.2.2/classes/ActionDispatch/Request.html).

```ruby
# app/models/visitor.rb
class Visitor < ApplicationRecord
  has_many :events
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
  serialize :params
  belongs_to :visitor
end
```

The value of `params` will be a `Hash` since we're getting that value from `request.query_parameters` or `request.request_parameters`. Calling [serialize](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html#method-i-serialize) will ensure the value of `params` is saved to the database as a serialized object, and also retrieved by deserializing into the same object.

### Create a new visitor record each time an anonymous user visits your site

```ruby
# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :visitor
end
```

The `Current` model is non-database backed, and inherits from [ActiveSupport::CurrentAttributes](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html) which keeps all the per-request attributes easily available to the whole system. This will store the current visitor between requests.

```ruby
# app/controllers/concerns/set_current_visitor.rb
module SetCurrentVisitor
  extend ActiveSupport::Concern

  included do
    before_action :set_current_visitor
  end

  private

  def set_current_visitor
    Current.visitor ||= Visitor.find_by(id: session[:visitor_id]) || create_current_visitor
  end

  def create_current_visitor
    visitor = Visitor.create!(
      user_agent: request.user_agent
    )
    session[:visitor_id] = visitor.id

    visitor
  end

end
```

The `SetCurrentVisitor` module is an [ActiveSupport::Concern](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html) that stores the logic for setting the current visitor. If the [session](https://guides.rubyonrails.org/action_controller_overview.html#session) contains a value for `visitor_id` that matches an existing `Visitor#id` then that record will be returned. Otherwise, a new visitor record will be created and saved in the `session`.

The `user_agent` is set to the value returned from the `request.user_agent` that is stored in the [request.headers](https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-headers). This value is used to tell what type of device and browser the visitor is using. This information can also be used to detect bots, which could affect data.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include SetCurrentVisitor
end
```

Including the `SetCurrentVisitor` module in the `ApplicationController` ensures the visitor is tracked on all requests.

### Track the visitor's events

```ruby
# app/controllers/concerns/track_event.rb
module TrackEvent
  extend ActiveSupport::Concern

  def track_event
    Current.visitor.events.create(
      path: request.path,
      method: request.method,
      params: event_params
    )
  end

  private

  def event_params
    request.query_parameters.presence || request.request_parameters.presence
  end
end
```

The `TrackEvent` module is an [ActiveSupport::Concern](https://api.rubyonrails.org/classes/ActiveSupport/Concern.html) that stores the logic for tracking a visitor's events. The `track_event` method simply takes the `path` and `method` returned from the [request](https://api.rubyonrails.org/classes/ActionDispatch/Request.html) and stores it on an `event` record that is associated with the current `visitor`. The private `event_params` method returns the value of [query_parameters](https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-query_parameters) or [request_parameters](https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters). Calling [presence](https://api.rubyonrails.org/classes/Object.html#method-i-presence) ensures the logical OR operator will work correctly.

The way in which the `TrackEvent` module is included will affect when and how `event` records are tracked.

Including the `TrackEvent` module in a Controller allows you to call the `track_event` method on specific actions. This is the least comprehensive approach, but also the most performant.

```ruby
# app/controllers/some_controller.rb
class SomeController < ApplicationController
  include TrackEvent

  def some_action
    track_event
  end
end
```

However, you could also use a [filter](https://guides.rubyonrails.org/action_controller_overview.html#filters) to call the `track_event` method on multiple actions.

```ruby
# app/controllers/some_controller.rb
class SomeController < ApplicationController
  include TrackEvent

  before_action :track_event
end
```

Finally, you could include the `TrackEvent` module in the `ApplicationController` and use a [filter](https://guides.rubyonrails.org/action_controller_overview.html#filters) to call the `track_event` method on all controller actions. This would allow you to track every event that every visitor makes.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include SetCurrentVisitor
  include TrackEvent

  before_action :track_event
end
```

This is the most comprehensive approach, but also the least performant. The risk with this approach is that an additional database call is made at the beginning of **every request for every visitor**. This could result in degraded performance across the entire application.

In all cases, the `track_event` method will return the newly created `event` object, but that return value is ignored. The goal is for the application to always execute each controller action even if the `track_event` method fails to create a new record.

## Filter sensitive data from event records

Extra care needs to be taken since we're saving the value of [request_parameters](https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters) into our `events`. Although [Rails automatically filters sensitive data from the logs](https://guides.rubyonrails.org/configuring.html#config-filter-parameters), it does not automatically filter sensitive data from being saved into the database.

This could be a problem if event records are created on sign up.

```ruby
class UserController < ApplicationController
  include TrackEvent

  def create
    track_event

    @user = User.create(user_params)
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

def
```

```ruby
Event.last.params
# => { user: { email: "user@example.com", password: "MyS3ktretPassword!" } }
```

Since `track_event` is being called on the `create` action, the values from the sign-up form will be saved to the event because they will be present in the [request_parameters](https://api.rubyonrails.org/classes/ActionDispatch/Request.html#method-i-request_parameters). Even though Rails filters the `password` parameter by default, this doesn't include when that value is saved to the database.

### Update TrackEvent module

```diff
--- a/app/controllers/concerns/track_event.rb
+++ b/app/controllers/concerns/track_event.rb
@@ -5,12 +5,20 @@ module TrackEvent
     Current.visitor.events.create(
       path: request.path,
       method: request.method,
-      params: event_params
+      params: filter_sensitive_data(event_params)
     )
   end

   private

+  def filter_sensitive_data(params)
+    return if params.nil?
+
+    ActiveSupport::ParameterFilter.new(
+      Rails.application.config.filter_parameters
+    ).filter(params)
+  end
+
   def event_params
     request.query_parameters.presence || request.request_parameters.presence
   end
```

The method responsible for setting the value of the `params` before saving it to an `event` can be refactored to filter out sensitive values. All that needs to be done is instantiate a new instance of [ActiveSupport::ParameterFilter](https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html) and pass it a hash of parameters to filter. Fortunately, that `hash` already exists in the form of [filtered_parameters](https://api.rubyonrails.org/classes/ActionDispatch/Http/FilterParameters.html#method-i-filtered_parameters). From there, calling [filter](https://api.rubyonrails.org/classes/ActiveSupport/ParameterFilter.html#method-i-filter) against the incoming parameters will ensure the output is filtered.

Now the `params` will be filtered before being saved on an `event` record.

```ruby
Event.last.params
# => { user: { email: "user@example.com", password: "[FILTERED]" } }
```

Rails ships with a set of defaults, but you can always modify this list by updating the `filter_parameter_logging` initializer.

```diff
--- a/config/initializers/filter_parameter_logging.rb
+++ b/config/initializers/filter_parameter_logging.rb
@@ -4,5 +4,5 @@
 # sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
 # notations and behaviors.
 Rails.application.config.filter_parameters += [
-  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
+  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :credit_
 ]
```

## Create event records in the background

It's possible to call `track_event` before every single request, which allows for every event a visitor makes to be tracked. This is the most comprehensive approach, but is also the least performant.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include SetCurrentVisitor
  include TrackEvent

  before_action :track_event
end
```

Creating a new `event` record per each request is a big hit to performance, since an extra request will be made to the database every time a visitor visits a page or fills out a form. Fortunately, this can be solved by leveraging [Active Job](https://guides.rubyonrails.org/active_job_basics.html)

### Create a job to create events in the background

This job simply wraps the logic needed to create an `event` record.

```ruby
# app/jobs/create_event_job.rb
class CreateEventJob < ApplicationJob
  queue_as :default

  def perform(visitor:, path:, method:, params:)
    visitor.events.create!(
      path: path,
      method: method,
      params: params
    )
  end
end
```

### Update the track_event method

Modifying the existing `track_event` method ensures all `event` records are created in the background.

Note that the `Current.visitor` is passed into the job, since the job is processed outside the request-cycle.

```diff
--- a/app/controllers/concerns/track_event.rb
+++ b/app/controllers/concerns/track_event.rb
@@ -2,7 +2,8 @@ module TrackEvent
   extend ActiveSupport::Concern

   def track_event
-    Current.visitor.events.create(
+    CreateEventJob.perform_later(
+      visitor: Current.visitor,
       path: request.path,
       method: request.method,
       params: filter_sensitive_data(event_params)
```

## Allow a visitor to enable their session to be tracked

A visitor should be given the opportunity to "opt-in" to being tracked in an effort to respect their right to privacy. This is even more important when tracking server-side events, since a visitor's [ad blocker](https://ublockorigin.com/) will not work.

### Create an endpoint to store the visitor's privacy preference

One approach is to store the visitor's preference in the [session](https://guides.rubyonrails.org/action_controller_overview.html#session). This demo assumes an "opt-in" approach, meaning that the visitor will not be tracked until they explicitly enable tracking.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  post "enable_analytics", to: "analytics#enable", as: :enable_analytics
end
```

```ruby
# app/controllers/analytics_controller.rb
class AnalyticsController < ApplicationController
  def enable
    session[:enable_analytics] = true

    redirect_to root_path, notice: "You have enabled your session to be tracked."
  end
end
```

```diff
--- a/app/views/layouts/application.html.erb
+++ b/app/views/layouts/application.html.erb
@@ -12,5 +12,8 @@

   <body>
     <%= yield %>
+    <% unless session[:enable_analytics] == true %>
+      <%= button_to "Enable Analytics", enable_analytics_path %>
+    <% end %>
   </body>
 </html>
```

### Refactor the SetCurrentVisitor and TrackEvent modules to respect the visitor's preference

As soon as a visitor enables tracking, the application will create a `visitor` record and start attaching `event` records to the `visitor`.

```diff
--- a/app/controllers/concerns/set_current_visitor.rb
+++ b/app/controllers/concerns/set_current_visitor.rb
@@ -2,7 +2,7 @@ module SetCurrentVisitor
   extend ActiveSupport::Concern

   included do
-    before_action :set_current_visitor
+    before_action :set_current_visitor, if: :should_set_current_visitor?
   end

   private
@@ -20,4 +20,8 @@ module SetCurrentVisitor
   def set_current_visitor
     Current.visitor ||= Visitor.find_by(id: session[:visitor_id]) || create_current_visitor
   end
+
+  def should_set_current_visitor?
+    session[:enable_analytics] == true
+  end
 end
```

```diff
--- a/app/controllers/concerns/track_event.rb
+++ b/app/controllers/concerns/track_event.rb
@@ -2,12 +2,14 @@ module TrackEvent
   extend ActiveSupport::Concern

   def track_event
-    CreateEventJob.perform_later(
-      visitor: Current.visitor,
-      path: request.path,
-      method: request.method,
-      params: filter_sensitive_data(event_params)
-    )
+    if session[:enable_analytics] == true
+      CreateEventJob.perform_later(
+        visitor: Current.visitor,
+        path: request.path,
+        method: request.method,
+        params: filter_sensitive_data(event_params)
+      )
+    end
   end

   private
```

## Create methods to return analytics

Tracking events is only valuable if the data can be queried. It's common to want to know how long a visitor is spending on the site, as well as how many times a page has been viewed.

### Query for time on site

Combining [ActiveRecord::QueryMethods](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html) with [aggregate functions](https://www.postgresql.org/docs/current/functions-aggregate.html) and [date/time functions and operators](https://www.postgresql.org/docs/current/functions-datetime.html) results in a query that returns a two-dimensional `array` where each item returned is a `visitors.id` and the amount of time in seconds that `visitor` spent on the site.

This is calculated by finding the difference between the `created_at` values of the `visitor's` first and last `events`. Because there are no `lower_bounds` or `upper_bounds` columns on the `visitors` table, [pluck](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-pluck) is called, since it returns attribute values. This allows [Arel.sql](https://api.rubyonrails.org/classes/Arel.html#method-c-sql) to be called within `pluck` in order to run the calculation.

```diff
--- a/app/models/visitor.rb
+++ b/app/models/visitor.rb
@@ -1,3 +1,21 @@
 class Visitor < ApplicationRecord
   has_many :events
+
+  def self.time_on_site
+    select("visitor_id, lower_bounds, upper_bounds")
+      .from(
+        Event
+          .select(
+            "visitor_id,
+            MIN(created_at) AS lower_bounds,
+            MAX(created_at) AS upper_bounds"
+          )
+          .group(:visitor_id)
+      )
+      .pluck(
+        "visitor_id",
+        Arel.sql("EXTRACT(EPOCH FROM (upper_bounds - lower_bounds))")
+      )
+      .sort
+  end
 end
```

```ruby
Visitor.time_on_site
# => [[3, 0.0], [1, 60.0], [2, 3660.0]]
```

### Query for page views

Combining [ActiveRecord::QueryMethods](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html) with [ActiveRecord::Calculations](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-count) results in a query that returns a `hash` where each item returned is the path visited along with how many times that page has been visited. Filtering the results [where](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where) the `method` is `GET` ensures results are limited to page views and does not include form submissions.

Using [distinct](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-distinct) along with [from](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-from) and [group](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-group) creates a query that returns unique page views by ignoring multiple page visits from a `visitor`.

```diff
--- a/app/models/event.rb
+++ b/app/models/event.rb
@@ -1,4 +1,24 @@
 class Event < ApplicationRecord
   serialize :params
   belongs_to :visitor
+
+  def self.page_views
+    select(:path)
+      .where(method: "GET")
+      .group(:path)
+      .count
+  end
+
+  def self.unique_page_views
+    select(:path)
+      .from(
+        Event
+          .select(:path, :visitor_id)
+          .distinct
+          .where(method: "GET")
+          .group(:path, :visitor_id)
+      )
+      .group(:path)
+      .count(:path)
+  end
 end
```

```ruby
Event.page_views
# => {"/" => 5, "/search" => 4}
Event.unique_page_views
# => {"/" => 3, "/search" => 1}
```

## Associate data with the current user

Right now, this data is completely anonymous, but it can be helpful to have it associated with an actual user to build a more accurate profile of each user. This comes with additional risks which will be addressed in subsequent sections.

### Associate a visitor with a user

Because a `user` may never sign up or sign in while visiting the site, it's necessary to keep this association [optional](https://guides.rubyonrails.org/association_basics.html#optional). This also means removing `null: false` from the database migration.

```ruby
# db/migrate/[timestamp]_add_user_id_to_visitors.rb
class AddUserIdToVisitors < ActiveRecord::Migration[7.0]
  def change
    add_reference :visitors, :user, foreign_key: true
  end
end
```

```diff
--- a/app/models/visitor.rb
+++ b/app/models/visitor.rb
@@ -1,4 +1,5 @@
 class Visitor < ApplicationRecord
+  belongs_to :user, optional: true
   has_many :events

   def self.time_on_site
```

### Associate the Current.visitor with the current_user

Because every application's authentication system is different, the implementation will vary. All that matters is that the value of the `user` on the `Current.visitor` is set to that of the `current_user`. Because a new `Current.visitor` is created each time the [session](https://guides.rubyonrails.org/action_controller_overview.html#session) resets, this ensures that a `user` will be associated with a new `visit` record each time they sign in to the application.

This is important because it will keep each `visit` and its associated `events` segmented, which is necessary in order to correctly calculate how much time a `user` has spent on the site.

```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
    ...
    Current.visitor.presence && Current.visitor.update!(user: current_user)
  end
end
```

```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def create
    ...
    Current.visitor.presence && Current.visitor.update!(user: current_user)
  end
end
```

## Create methods to return user analytics

Now that a `visit` is being associated with a `user` it will be helpful to create additional queries to return analytics on `user` accounts.

### Query for time on site per visitor

Creating a separate `time_on_site_for_visitor` [scope](https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-scope) that returns the most recent and oldest `created_at` values per `visitor` allows that query to be chained with [ActiveRecord::Calculations](https://api.rubyonrails.org/classes/ActiveRecord/Calculations.html#method-i-average) methods. This also allows the query to be cleanly reused in the `total_time_on_site_for_visitor` and `average_time_on_site_for_visitor` class methods.

Each class method has access to the virtual `upper_bounds` and `lower_bounds` columns passed in from the `time_on_site_for_visitor` scope. This makes it possible to use those values in [Arel.sql](https://api.rubyonrails.org/classes/Arel.html#method-c-sql).

```diff
--- a/app/models/visitor.rb
+++ b/app/models/visitor.rb
@@ -2,6 +2,20 @@ class Visitor < ApplicationRecord
   belongs_to :user, optional: true
   has_many :events

+  scope :time_on_site_for_visitor, ->(visitor) {
+    select("lower_bounds, upper_bounds")
+      .from(
+        Event
+        .select(
+          "visitor_id,
+          MIN(created_at) AS lower_bounds,
+          MAX(created_at) AS upper_bounds"
+        )
+        .where(visitor: visitor)
+        .group(:visitor_id)
+      )
+  }
+
   def self.time_on_site
     select("visitor_id, lower_bounds, upper_bounds")
       .from(
@@ -19,4 +33,16 @@ class Visitor < ApplicationRecord
       )
       .sort
   end
+
+  def self.total_time_on_site_for_visitor(visitor)
+    time_on_site_for_visitor(visitor).sum(
+      Arel.sql("EXTRACT(EPOCH FROM (upper_bounds - lower_bounds))")
+    )
+  end
+
+  def self.average_time_on_site_for_visitor(visitor)
+    time_on_site_for_visitor(visitor).average(
+      Arel.sql("EXTRACT(EPOCH FROM (upper_bounds - lower_bounds))")
+    )
+  end
 end
```

### Query for time on site per user and associate a user with an event and a visit.

The queries created in the previous step can be easily reused in instance methods on the `user`.

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :visits, class_name: "Visitor"
  has_many :events, through: :visits

  def time_on_site
    Visitor.total_time_on_site_for_visitor(visits)
  end

  def average_time_on_site
    Visitor.average_time_on_site_for_visitor(visits)
  end
end
```

```ruby
User.first.time_on_site
# Time in seconds
# => 3600
User.first.average_time_on_site
# Time in seconds
# => 2730
```

Additionally, the use of [has_many](https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many) adds the ability to query for `event` and `visit` records on the `user`.

```ruby
User.first.events
# The user's entire event history.
# => [#<Event>, #<Event>]
User.first.visits
# Each of the user's visits.
# => [#<Visitor>, #<Visitor>]
```

## Provide multiple mechanisms for clearing user history

It's important to provide multiple mechanisms for clearing user history in an effort to reduce risk and keep your user's privacy in mind.

### Update migrations to ensure associated data is deleted automatically

Updating the existing migrations to use a [cascading foreign key](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key-label-Creating+a+cascading+foreign+key) ensure that when a `user` is deleted from the database their associated `visitor` and `event` records will be automatically deleted too.

An alternative approach is to use `dependent: :destroy` in the associated models, but this is less performant because it will iterate through each record in order to trigger any callbacks or validations.

```diff
--- a/db/migrate/[timestamp]_create_events.rb
+++ b/db/migrate/[timestamp]_create_events.rb
@@ -4,7 +4,7 @@ class CreateEvents < ActiveRecord::Migration[7.0]
       t.string :path, null: false
       t.string :method, null: false
       t.string :params
-      t.references :visitor, null: false, foreign_key: true
+      t.references :visitor, null: false, foreign_key: {on_delete: :cascade}

       t.timestamps
     end
```

```diff
--- a/db/migrate/[timestamp]_add_user_id_to_visitors.rb
+++ b/db/migrate/[timestamp]_add_user_id_to_visitors.rb
@@ -1,5 +1,5 @@
 class AddUserIdToVisitors < ActiveRecord::Migration[7.0]
   def change
-    add_reference :visitors, :user, foreign_key: true
+    add_reference :visitors, :user, foreign_key: {on_delete: :cascade}
   end
 end
```

### Create an endpoint allowing a user to clear their history on-demand

It's common to allow a user to be able to clear their history. Adding this endpoint ensures they have a way to do this on-demand.

```diff
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -8,4 +8,5 @@ Rails.application.routes.draw do
   post "sign_up", to: "pages#sign_up", as: :sign_up
   post "sign_in", to: "pages#sign_in", as: :sign_in
   post "enable_analytics", to: "analytics#enable", as: :enable_analytics
+  delete "clear_history", to: "analytics#clear_history", as: :clear_history
 end
```

```diff
--- a/app/controllers/analytics_controller.rb
+++ b/app/controllers/analytics_controller.rb
@@ -4,4 +4,11 @@ class AnalyticsController < ApplicationController

     redirect_to root_path, notice: "You have enabled your session to be tracked."
   end
+
+  def clear_history
+    current_user.visits.destroy_all
+
+    redirect_to root_path, notice: "History deleted."
+  end
 end
```

The updates made to the `foreign_key` option in the existing migrations make it so that calling [destroy_all](https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-destroy_all) will also delete the user's associated `event` records.

### Create a mechanism to delete history older than a certain date

Adding a mechanism to delete user history that is older than a certain date should be considered in order to reduce risk (and database space).

```diff
--- a/app/models/visitor.rb
+++ b/app/models/visitor.rb
@@ -45,4 +45,8 @@ class Visitor < ApplicationRecord
       Arel.sql("EXTRACT(EPOCH FROM (upper_bounds - lower_bounds))")
     )
   end
+
+  def self.delete_all_older_than(timestamp)
+    destroy_by("created_at < ?", timestamp)
+  end
 end
```

```ruby
Visitor.delete_all_older_than(6.months.ago)
```

Using [destroy_by](https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-destroy_by) makes this easy. Consider scheduling a recurring [job](https://guides.rubyonrails.org/active_job_basics.html) to call this method.

## Wrapping up

Creating a transparent "opt-in" tracking approach in combination with allowing users to delete their history helps foster trust between you and your user base. This trust is just as valuable as any metrics you'll capture.
