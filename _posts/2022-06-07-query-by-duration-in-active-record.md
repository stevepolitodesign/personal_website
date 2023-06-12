---
title: "Query by Duration in Active Record"
excerpt: "
  How do you even save a “duration”, let alone query for records by that value?
  It’s actually easier than you think.
  "
categories: ["Ruby on Rails"]
tags: ["PostgreSQL"]
canonical_url: https://thoughtbot.com/blog/query-by-duration-in-active-record
---

In this tutorial, we’ll learn how to query and group records by duration using Active Record. If at any point you wish to explore on your own, simply clone or fork the [example repository](https://github.com/thoughtbot/active-record-recipes) on which this post references.

Let’s get cooking!

## Our domain

Below are the models and their associations we'll be using for this exercise.

```ruby
class Recipe < ApplicationRecord
  has_many :steps
end

class Step < ApplicationRecord
  belongs_to :recipe
end
```

## Store duration as an interval and not an integer

It might be tempting to store the duration as an integer in a **duration_in_seconds** column. However, PostgreSQL provides a better solution to this problem with its [interval](https://www.postgresql.org/docs/14/datatype-datetime.html#DATATYPE-INTERVAL-INPUT) datatype. What's more, [Rails provides an abstraction around this datatype](https://guides.rubyonrails.org/v7.0.3/active_record_postgresql.html#interval) that can be used in migrations.

```ruby
class CreateSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :steps do |t|
      t.interval :duration
      ...
    end
  end
end
```

This is not only semantically correct, but also makes for a cleaner interface. It means we can add records like this:

```ruby
step = Step.new(duration: 10.minutes)
step.duration
# => 10.minutes
```

## Query for records by their duration

Let’s start simple and query for **steps** by their duration.

```ruby
Step.where(duration: 10.minutes)
# => [#<Step>]
```

This is easy because we can query against the table that has the **duration** without needing to run any calculations.

However, that will just query for all records whose duration is exactly 10 minutes. Passing an [endless range](https://ruby-doc.org/core-3.1.2/Range.html#class-Range-label-Endless+Ranges) will use a comparison operator.

```ruby
Step.where(duration: ..10.minutes)
# => [#<Step>, #<Step>]
```

Note that the use of two dots will result in a less than or equal comparison, while the use of three dots will in a less than comparison.

```ruby
Step.where(duration: ..10.minutes).to_sql
# => SELECT "steps".* FROM "steps" WHERE "steps"."duration" <= 'PT10M'
Step.where(duration: ...10.minutes).to_sql
# => SELECT "steps".* FROM "steps" WHERE "steps"."duration" < 'PT10M'
```

If you cannot use a [hash condition](https://api.rubyonrails.org/v7.0.3/classes/ActiveRecord/QueryMethods.html#method-i-where-label-hash), you'll need to cast `10.minutes` to [iso8601](https://api.rubyonrails.org/v7.0.3/classes/ActiveSupport/Duration.html#method-i-iso8601) so that it will be compatible with the [PostgreSQL interval output](https://www.postgresql.org/docs/14/datatype-datetime.html#DATATYPE-INTERVAL-OUTPUT).

```ruby
Step.where("duration >= ?", 10.minutes.iso8601)
# => [#<Step>, #<Step>]
```

If you call [to_sql](https://api.rubyonrails.org/v7.0.3/classes/ActiveRecord/Relation.html#method-i-to_sql) you can see that the comparison is made against `PT10M` since this is what PostgreSQL expects.

```ruby
Step.where("duration >= ?", 10.minutes.iso8601).to_sql
# => SELECT "steps".* FROM "steps" WHERE (duration >= 'PT10M')

10.minutes.iso8601
# => "PT10M"
```

## Query for records by duration through an association

Let’s turn up the heat by querying for **recipes** by their duration. This is more challenging because the **recipe** does not have a duration column. Not only that, but a **recipe** has many **steps**, not just one, and each **step** could have a duration.

```ruby
class Recipe < ApplicationRecord
  has_many :steps

  def self.with_duration_less_than, -> (duration){
    joins(:steps)
      .group(:id)
      .having("SUM(steps.duration) <= ?", duration.iso8601)
  }
end

Recipe.with_duration_less_than(60.minutes)
# => [#<Recipe>, #<Recipe>]
```

The use of [joins](https://api.rubyonrails.org/v7.0.3/classes/ActiveRecord/QueryMethods.html#method-i-joins) allows access to the associated **steps** table, which in turn allows access to the **duration** column. From there, we can call [having](https://api.rubyonrails.org/v7.0.3/classes/ActiveRecord/QueryMethods.html#method-i-having) to filter out rows that do not meet the specified criteria.

## Grouping records by duration

Now for the pièce de résistance: Let's group **recipes** by their duration. By using a combination of [group](https://api.rubyonrails.org/v7.0.3/classes/ActiveRecord/QueryMethods.html#method-i-group) and [sum](https://api.rubyonrails.org/v7.0.3/classes/ActiveRecord/Calculations.html#method-i-sum) while leveraging [order](https://api.rubyonrails.org/v7.0.3/classes/ActiveRecord/QueryMethods.html#method-i-order) we can group **recipes** by their duration sorted from quickest to longest.

```ruby
class Recipe < ApplicationRecord
  has_many :steps

  def self.by_duration
    joins(:steps)
      .group(:name)
      .order("SUM(steps.duration) ASC")
      .sum(:duration)
  end
end

Recipe.by_duration
# => {"Recipe Two"=>5 minutes, "Recipe One"=>25 minutes}
```

## Hungry for more?

Check out [our cookbook](https://github.com/thoughtbot/active-record-recipes) for more active record recipes!
