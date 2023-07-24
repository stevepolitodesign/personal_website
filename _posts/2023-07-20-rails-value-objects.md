---
title: Building Value Objects in Rails with composed_of
category: [Ruby on Rails]
excerpt: Learn how to improve the interface of your existing Active Record Models with this underutilized API.
canonical_url: https://thoughtbot.com/blog/rails-value-objects
---

In this tutorial, we'll explore how we can improve the interface of an Active
Record Model by extracting existing logic into [value objects][] by using Rails'
[composed_of][] macro.

## Setup

Below is our starting point. We have a `Run` model that has `duration`,
`distance` and `unit` attributes.

```ruby
# /db/migrate/[timestamp]_create_runs.rb
class CreateRuns < ActiveRecord::Migration[7.0]
  def change
    create_table :runs do |t|
      t.interval :duration
      t.decimal :distance, null: false
      t.string :unit, null:  false

      t.timestamps
    end
  end
end
```

It also has a `convert_to` method powered by [ruby-units][] that converts the
run's distance into another unit of measurement.

```ruby
# /app/models/run.rb
class Run < ApplicationRecord
  validates :unit, inclusion: { in: %w(mi m km) }

  def convert_to(new_unit)
    Unit.new("#{distance} #{unit}").convert_to(new_unit)
  end
end
```

```ruby
run = Run.new(distance: 5, unit: "km")
run.convert_to("mi")

=> 3.10686 mi
```

## Limitations with existing interface

Although the `convert_to` method returns a new `Unit` instance, our `Run` model
does not offer a simple way to interface with the instance of that `Unit`.

For example, if we want to compare distances of varying units, we need to do
something like this:

```ruby
unit_5_km = Run.new(distance: 5, unit: "km").convert_to("km")
unit_3_mi = Run.new(distance: 3, unit: "mi").convert_to("mi")

unit_5_km > unit_3_mi
# => true
```

It would be preferable if we could call a method directly on `Run` to return a
new `Unit` instance without needing to pass a redundant argument.

## Improving our interface with `composed_of`

Fortunately Rails provides an API for representing attributes as value objects
via the [composed_of][] macro.

### Adding a measurement attribute

Let's improve our interface by adding `Run#measurement` which will return a new
`Unit` instance.

```diff
 class Run < ApplicationRecord
+  composed_of :measurement,
+              class_name: "Unit",
+              mapping: [ %w(distance scalar), %w(unit units) ]
+
   validates :unit, inclusion: { in: %w(mi m km) }

   def convert_to(new_unit)
```

We need to set the `class_name` to `"Unit"` since the class name cannot be
inferred via the `:measurement` attribute. By default, Rails would have looked
for a `Measurement` class.

We also set the `mapping` so that the value of `distance` is set as the `scalar`
value on the `Unit` instance, and the value of `unit` is set as the `units`
value on the `Unit` instance. You can think of it like this:

```ruby
run = Run.new(distance: 5, unit: "km", duration: 15.minutes)
unit = Unit.new(run.distance, run.unit)
# => 5 km

unit.scalar
# => 5

unit.units
# => "km"
```

With this change, we now have access to the `Unit` class via the `measurement`
attribute. Prior to this commit, `Run#convert_to` was the only way to interact
with the `Unit` instance. Now we can call `Run#measurement`.

```ruby
run = Run.new(distance: 5, unit: "km")

run.measurement
# => 5 km

run.measurement.scalar
# => 5

run.measurement.units
# => "km"

run.measurement > Run.new(distance: 3, unit: "mi").measurement
# => true
```

Now that we have a value object to work with, we can refactor our `convert_to`
method.

```diff
   validates :unit, inclusion: { in: %w(mi m km) }

   def convert_to(new_unit)
-    Unit.new("#{distance} #{unit}").convert_to(new_unit)
+    measurement.convert_to(new_unit)
   end
 end
```

### Allow measurement to be set via a string

The [composed_of][] macro also allows us to set the `measurement` attribute (and
therefor the `distance` and `unit` attributes) like so:

```ruby
run = Run.new
run.measurement = Unit.new("1 mi")

run.distance
# => 1

run.unit
# => "mi"
```

However, we can improve this interface by using the `converter` option. The
`converter` option takes the value passed to the `measurement` attribute and
calls a Proc to correctly initialize the `Unit` class.

```diff
 class Run < ApplicationRecord
   composed_of :measurement,
               class_name: "Unit",
-              mapping: [ %w(distance scalar), %w(unit units) ]
+              mapping: [ %w(distance scalar), %w(unit units) ],
+              converter: Proc.new { |value| Unit.new(value) }

   validates :unit, inclusion: { in: %w(mi m km) }

```

Now we can do something like this:

```ruby
run = Run.new
run.measurement = "1 mi"

run.distance
# => 1

run.unit
# => "mi"
```

### Query by `measurement`

The `composed_of` macro also allows us to query by the attribute with [where][]
or [find_by][].

```ruby
mile = Run.create(distance: 1, unit: "mi")

Run.where(measurement: Unit.new("1 mi"))
# => #<ActiveRecord::Relation [#<Run>]>

Run.find_by(measurement: Unit.new("1 mi"))
# => #<Run>
```

However, there is a limitation with this API. It creates a naive `WHERE` clause
based on the attributes used in the `mapping`. The example below demonstrates
how two `run` records with the same converted distance need to be queried
separately.

```ruby
mile = Run.create(distance: 1, unit: "mi")
mile_in_meters = Run.create(distance: 1609.344, unit: "m")

Run.where(measurement: Unit.new("1 mi")).count
# => 1

Run.where(measurement: Unit.new("1609.344 m")).count
# => 1

puts Run.where(measurement: Unit.new("1 m")).to_sql
# => SELECT "runs".* FROM "runs" WHERE "runs"."distance" = 1 AND "runs"."unit" = 'm'

puts Run.where(measurement: Unit.new("1609.344 m")).to_sql
# => SELECT "runs".* FROM "runs" WHERE "runs"."distance" = 1609.344 AND "runs"."unit" = 'm'
```

## Calculating pace

Now that we have a basic understanding of how `compose_of` works, let's extend
our `Run` class by adding the ability to calculate pace.

```diff
   def convert_to(new_unit)
     measurement.convert_to(new_unit)
   end
+
+  def pace(measurement = "mi")
+    unit     = Unit.new(measurement)
+    interval = (self.convert_to(unit).scalar.to_f / unit.scalar.to_f)
+    split    = duration.in_seconds / interval
+    duration = formatted_time(split)
+
+    if unit.scalar == 1
+      "#{duration} per #{unit.units}"
+    else
+      "#{duration} per #{unit}"
+    end
+  end
+
+  private
+
+  def formatted_time(total_seconds)
+    total_seconds = total_seconds.round
+    minutes = total_seconds / 60
+    seconds = total_seconds % 60
+
+    "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
+  end
 end
```

```ruby
run = Run.new(duration: 14.minutes + 41.seconds, measurement: "5 km")

run.pace
# => "4:44 per mi"

run.pace("km")
# => "2:56 per km"

run.pace("3 km")
# => "8:49 per 3km"
```

This is a good start, but it would be better if we returned an object instead of
a `String`. Doing so would allow us to operate against the `duration` and `unit`
individually, as well as compare paces from different runs, even if they're
using different units of measurement.

### Introduce pace attribute

We can refactor the previous implementation by once again leveraging
[composed_of][].

```diff
               class_name: "Unit",
               mapping: [ %w(distance scalar), %w(unit units) ],
               converter: Proc.new { |value| Unit.new(value) }
+  composed_of :pace,
+              mapping: [ %w(duration duration), %w(distance distance), %w(unit unit)],
+              constructor: Proc.new { |duration, distance, unit| Pace.new(duration: duration, distance: distance, unit: unit) }

   validates :unit, inclusion: { in: %w(mi m km) }

-  def pace(measurement = "mi")
-    unit     = Unit.new(measurement)
-    interval = (self.convert_to(unit).scalar.to_f / unit.scalar.to_f)
-    split    = duration.in_seconds / interval
-    duration = formatted_time(split)
-
-    if unit.scalar == 1
-      "#{duration} per #{unit.units}"
-    else
-      "#{duration} per #{unit}"
-    end
-  end
-
-  private
-
-  def formatted_time(total_seconds)
-    total_seconds = total_seconds.round
-    minutes = total_seconds / 60
-    seconds = total_seconds % 60
-
-    "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
-  end
 end
```

Below is our new `Pace` class, which provides a richer interface when compared
to the previous implementation which just returned a `String`.

```ruby
# app/models/pace.rb
class Pace
  include Comparable
  attr_reader :duration, :distance, :unit, :measurement

  def initialize(duration:, distance:, unit:)
    @duration = duration
    @distance = distance
    @unit = unit
    @measurement = Unit.new(distance, unit)
  end

  def split(measurement = "1 mi")
    unit     = Unit.new(measurement)
    interval = (self.measurement.convert_to(unit).scalar.to_f / unit.scalar.to_f)
    split    = (duration.in_seconds / interval).round
    duration = ActiveSupport::Duration.build(split)

    Split.new(duration: duration, distance: unit)
  end

  def >(other)
    self.split.duration > other.split.duration
  end

  def <(other)
    self.split.duration < other.split.duration
  end

  def ==(other)
    self.split.duration == other.split.duration
  end

  class Split
    attr_reader :duration, :distance

    def initialize(duration:, distance:)
      @duration = duration
      @distance = distance
    end

    def inspect
      calculate
    end

    def to_s
      calculate
    end

    private

    def calculate
      unit            = Unit.new(distance)
      parsed_duration = formatted_time(duration)

      if unit.scalar == 1
        "#{parsed_duration} per #{unit.units}"
      else
        "#{parsed_duration} per #{unit}"
      end
    end

    def formatted_time(total_seconds)
      total_seconds = total_seconds.round
      minutes = total_seconds / 60
      seconds = total_seconds % 60

      "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
    end
  end
end
```

Now we can calculate the pace off of the `pace` attribute instead.

```ruby
run = Run.new(duration: 14.minutes + 41.seconds, measurement: "5 km")

run.pace.split
# => 4:44 per mi

run.pace.split("km")
# => 2:56 per km

run.pace.split("3 km")
# => 8:49 per 3km
```

The advantage to this approach is that we can now compare paces, which was not
possible with the previous implementation.

```ruby
run_5_km = Run.new(duration: 15.minutes, measurement: "5 km")
run_1_mi = Run.new(duration: 5.minutes, measurement: "1 mi")

run_5_km.pace < run_1_mi.pace
# => true
```

You'll also note that we used the `constructor` option when declaring our `pace`
attribute. Without this option, we would raise the following error:

```ruby
ArgumentError: wrong number of arguments (given 3, expected 0; required keywords: duration, distance, unit)
```

This is because our `Pace` class uses keyword arguments and not positional
arguments.

#### Allow pace to be set by a string

Similar to the `measurement` attribute, setting the `pace` attribute will
populate the `duration`, `distance`, `unit` , and even the `measurement`
attributes.

```ruby
run = Run.new
run.pace = Pace.new(duration: 15.minutes, distance: "5", unit: "km")

run.duration
# => 15 minutes

run.distance
# => 5

run.unit
# => "km"

run.measurement
# => 5 km
```

However, we can improve our interface by allowing the `pace` to be set by a
`Hash` by adding the `converter` option.

```diff
               converter: Proc.new { |value| Unit.new(value) }
   composed_of :pace,
               mapping: [ %w(duration duration), %w(distance distance), %w(unit unit)],
-              constructor: Proc.new { |duration, distance, unit| Pace.new(duration: duration, distance: distance, unit: unit) }
+              constructor: Proc.new { |duration, distance, unit| Pace.new(duration: duration, distance: distance, unit: unit) },
+              converter: Proc.new { |hash|
+                hash                      = hash.symbolize_keys
+                unit                      = Unit.new(hash[:unit])
+                measurement               = Unit.new(hash[:measurement])
+                minutes, seconds          = hash[:duration].split(":").map(&:to_i)
+                total_duration_in_seconds = ((minutes * 60 + seconds) * measurement.convert_to(unit).scalar).floor
+                duration                  = ActiveSupport::Duration.build(total_duration_in_seconds)
+
+                Pace.new(duration: duration, distance: measurement.scalar, unit: measurement.units)
+              }

   validates :unit, inclusion: { in: %w(mi m km) }
```

Now instead of passing a new instance of a `Pace`, we can pass something more
useful that actually encodes the pace directly.

```ruby
run = Run.new
run.pace = {duration: "4:50", unit: "1 mi",  measurement: "5 km"}

run.duration
# => 15 minutes

run.distance
# => 5

run.unit
# => "km"

run.measurement
# => 5 km
```

[ruby-units]: https://github.com/olbrich/ruby-units
[composed_of]: https://api.rubyonrails.org/classes/ActiveRecord/Aggregations/ClassMethods.html#method-i-composed_of
[where]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where
[find_by]: https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find_by
[value objects]: https://thoughtbot.com/upcase/videos/value-objects
