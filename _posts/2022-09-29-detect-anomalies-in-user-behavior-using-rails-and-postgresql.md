---
title: "Detect anomalies in user behavior using Rails and PostgreSQL"
excerpt: "
  You probably use some type of error monitoring software to notify you when an
  exception is raised in your application, but are you being notified when there
  is an anomaly in user behavior?
  "
categories: ["Ruby on Rails"]
tags: ["PostgreSQL"]
canonical_url: https://thoughtbot.com/blog/detect-anomalies-in-user-behavior-using-rails-and-postgresql
---

Let’s focus on a metric that nearly all applications should be monitoring: The
number of sign-ups per day. Wouldn’t it be nice to know if all of a sudden that
number dropped significantly?

The first thing we’ll need to do is to group users by the date they signed up,
or in other words, group users by the date they were _created._

```ruby
ActiveRecord::Base.connection.exec_query(
  <<-SQL
    SELECT COUNT(*) AS total_sign_ups, created_at::date as date
    FROM users
    GROUP BY created_at::date
    ORDER BY created_at::date DESC
  SQL
).to_a
# => [{"total_sign_ups"=>99, "date"=>"2022-07-15"}, ...]
```

<aside class="info">
💡 You’ll note that we need to <a href="https://www.postgresql.org/docs/14/sql-expressions.html#SQL-SYNTAX-TYPE-CASTS">type cast</a> the <strong>created_at</strong> column from a <strong>datetime</strong> to a <strong>date</strong>. Otherwise, users will be grouped by the exact second they were created.
</aside>

Now that we know how to group users by the date they signed up, we can figure
out how many users sign up per day on average.

```ruby
ActiveRecord::Base.connection.exec_query(
  <<-SQL
    SELECT
      AVG(users.total_sign_ups) AS sign_ups_per_day_on_average
    FROM(
      SELECT COUNT(*) AS total_sign_ups FROM users
      GROUP BY created_at::date
    )
    AS users LIMIT 1
  SQL
).to_a
# => [{"sign_ups_per_day_on_average"=>100}]
```

Now that we have our baseline, we can detect anomalies and be alerted when they
occur.

```ruby
sign_ups_per_day_on_average = ActiveRecord::Base.connection.exec_query(
  <<-SQL
    SELECT
      AVG(users.total_sign_ups) AS sign_ups_per_day_on_average
    FROM(
      SELECT COUNT(*) AS total_sign_ups FROM users
      GROUP BY created_at::date
    ) AS users LIMIT 1
  SQL
).to_a.first["sign_ups_per_day_on_average"]
# => 100

sign_ups_today = User.where("created_at::date = ?", Time.now).count
# => 99

# This can be run in a daily cron job
if sign_ups_today < sign_ups_per_day_on_average
  raise Anomaly::UserSignUpAnomaly
end
```

However, this is not the most accurate way to detect anomalies. Although there
were fewer sign-ups today than the average, we were only off by one. I'd hardly
consider that an anomaly. What we need to consider is [standard
deviation](https://en.wikipedia.org/wiki/Standard_deviation). Fortunately,
PostgreSQL has us covered with its [Aggregate Functions for
Statistics](https://www.postgresql.org/docs/14/functions-aggregate.html#FUNCTIONS-AGGREGATE-STATISTICS-TABLE).

We can use the **STDDEV_SAMP** function to iterate through each row and return
the standard deviation for sign-ups per day. Then, we can see if the number of
sign-ups on a particular day is within 1 standard deviation of the average.

```ruby
result = ActiveRecord::Base.connection.exec_query(
  <<-SQL
    SELECT
      AVG(total_sign_ups) AS sign_ups_per_day_on_average,
      STDDEV_SAMP(total_sign_ups) AS standard_deviation
    FROM(
      SELECT COUNT(*) AS total_sign_ups FROM users
      GROUP BY created_at::date
    ) AS users LIMIT 1
  SQL
).to_a
# => [{"sign_ups_per_day_on_average"=>100, "standard_deviation"=>5}]

sign_ups_today = User.where("created_at::date = ?", Date.current).count
# => 99

lower_bounds = result.first["sign_ups_per_day_on_average"] - result.first["standard_deviation"]
# => 95

# This can be run in a daily cron job
if sign_ups_today < lower_bounds
  raise Anomaly::UserSignUpAnomaly
end
```

Since the average number of sign-ups per day is 100, and the standard deviation
is 5, that means in a [normal
distribution](https://en.wikipedia.org/wiki/Normal_distribution) 68% of the time
the number of sign-ups per day should be between 95 and 105 (1 standard
deviation), and 95% of the time the number of sign-ups per day should be between
90 and 100 (2 standard deviations).

In our example, we'll assume that 1 standard deviation is enough to warrant an
anomaly. Since we're only interested in a drop in sign-ups, we'll compare the
number of sign-up today with 95.

We don’t have to stop there, though. We can leverage the power of SQL to tell us
if the result was an anomaly without needing to use Ruby. All we need is a [case
statement](https://www.postgresql.org/docs/14/plpgsql-control-structures.html#id-1.8.8.8.6.6)
and a sub-query.

```ruby
result = ActiveRecord::Base.connection.exec_query(
  <<-SQL
    SELECT
      sign_ups_today,
      CASE
        WHEN sign_ups_today >= sign_ups_per_day_on_average - COALESCE(standard_deviation, 0) THEN false
        ELSE true
      END AS anomaly
    FROM(
      SELECT
        AVG(total_sign_ups) AS sign_ups_per_day_on_average,
        STDDEV_SAMP(total_sign_ups) AS standard_deviation,
        (
          SELECT COUNT(*) AS sign_ups_today
          FROM users
          WHERE created_at::date='#{Date.current}'
        )
      FROM(
        SELECT COUNT(*) AS total_sign_ups FROM users
        GROUP BY created_at::date
      ) AS users
    ) AS sign_ups_today LIMIT 1
  SQL
).to_a
# => [{"sign_ups_today"=>99, "anomaly"=>false}]

# This can be run in a daily cron job
if result.first["anomaly"]
  raise Anomaly::UserSignUpAnomaly
end
```

The sub-query creates a table that returns the
**sign_ups_per_day_on_average** and the **standard_deviation**. This allows
us to use a **CASE** statement on the calculated result from those two columns
when compared to **sign_ups_today** rather than doing the calculation in Ruby.

Note that we use
[COALESCE](https://www.postgresql.org/docs/14/functions-conditional.html#FUNCTIONS-COALESCE-NVL-IFNULL)
to set the value of the **standard_deviation** to **0** if no value is returned.
This can happen when there is not enough data to calculate the standard
deviation. This fallback simply compares the number of signs up to the average
number of sign-ups.

This pattern doesn’t have to be limited to user sign-ups. It can be applied to
any action on your system, such as the number of items purchased per day, or the
number of comments posted per day. If you find that the data you need to query
doesn’t exist in your system, consider [tracking those
events](https://thoughtbot.com/blog/rails-server-side-analytics-from-scratch) in
a custom database table.
