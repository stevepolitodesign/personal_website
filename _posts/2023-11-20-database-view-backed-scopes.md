---
title: Database View Backed Scopes In Rails
excerpt: How do you manage queries when your Rails application isn't the only thing reading your database?
categories: ["Ruby on Rails"]
tags: ["PostgreSQL", "Active Record"]
canonical_url: https://thoughtbot.com/blog/database-view-backed-scopes
---

I'm on project that has a separate data team. The data team has direct access to
our database so that they can run reports without having to interface with the
Rails application. One of those reports is to return all bills that are eligible
for payment.

Our application currently has a [scope][] to run that query, but unfortunately
the data team cannot utilize it because they only have access to the database.
Although I could have called [to_sql][] on the scope and shared the query, my
concern was that the application code and SQL query could drift over time.

Instead, I wanted to see if it was possible to create a more holistic solution
by leveraging a [database view][]. This would allow the data team to query
that view directly, while also allowing the application to use that view in the
existing scope. If the query ever needs to change, it only needs to change in
one place.

## Our base

Here's the domain and scopes we'll be working with in this tutorial. Although
they're not too complex, they still run the risk of changing. If this is the
case, we'd need to communicate that to the data team so they can update their
queries.

```ruby
# Schema: bills[ id, amount_in_cents, created_at, updated_at ]
class Bill < ApplicationRecord
  has_many :payments, dependent: :destroy

  scope :eligible_for_payment, -> {
    left_joins(:payments)
      .group("bills.id")
      .having(<<~SQL)
        sum(payments.amount_in_cents) < bills.amount_in_cents or
        (bills.amount_in_cents > 0 and count(payments.id) = 0)
      SQL
  }
  scope :ineligible_for_payment, -> { excluding(eligible_for_payment) }
end

# Schema: payments[ id, bill_id, amount_in_cents, created_at, updated_at ]
class Payment < ApplicationRecord
  belongs_to :bill
end
```

## Create a database view

The first thing we'll want to do is install the [scenic][] gem. Although this is
not required to create a [database view][] in Rails, it improves the developer
experience.

<aside class="info">
    If you want to learn more about scenic, we have an <a
href="https://thoughtbot.com/upcase/videos/database-views-with-scenic">Upcase
tutorial</a> you might enjoy.
</aside>

Once installed, generate a new view and populate it with the query.

```
rails g scenic:view bill_eligible_for_payments
```

I simply copied the output of `puts Bill.eligible_for_payment.to_sql`.

```sql
-- db/views/bill_eligible_for_payments_v01.sql
SELECT "bills".* FROM "bills"
LEFT OUTER JOIN "payments" ON "payments"."bill_id" = "bills"."id"
GROUP BY "bills"."id"
HAVING (
  SUM(payments.amount_in_cents) < bills.amount_in_cents OR
  (bills.amount_in_cents > 0 AND COUNT(payments.id) = 0)
)
```

Finally, add a corresponding model and run the migrations.

```ruby
# app/models/bill/eligible_for_payment.rb

class Bill::EligibleForPayment < ApplicationRecord
end
```

If we enter the `console`, we should be able to call
`Bill::EligibleForPayment.all` and see a result set.

## Update the scope

Now that we have a database view and corresponding model, let's update our
scope.

At first, you might think we can do something like this:

```diff
--- a/app/models/bill.rb
+++ b/app/models/bill.rb
@@ -2,12 +2,7 @@ class Bill < ApplicationRecord
   has_many :payments, dependent: :destroy

   scope :eligible_for_payment, -> {
-    left_joins(:payments)
-      .group("bills.id")
-      .having(<<~SQL)
-        sum(payments.amount_in_cents) < bills.amount_in_cents or
-        (bills.amount_in_cents > 0 and count(payments.id) = 0)
-      SQL
+    Bill::EligibleForPayment.all
   }
   scope :ineligible_for_payment, -> { excluding(eligible_for_payment) }
 end
```

However, this does not work as expected. If we open the `console` and run
`Bill.eligible_for_payment`, we see that it returns instances of
`Bill::EligibleForPayment` and not of `Bill`.

```ruby
Bill.eligible_for_payment

# => [#<Bill::EligibleForPayment>, #<Bill::EligibleForPayment>]
```

Additionally, this means that this scope does not build upon the previous
scope. It will always return instances of `Bill::EligibleForPayment`.
We can see this by running [to_sql][] in the query. Note that it ignores the
`where` clause altogether.

```ruby
puts Bill.where(amount_in_cents: 0..1).eligible_for_payment.to_sql

SELECT "bill_eligible_for_payments".* FROM "bill_eligible_for_payments"
=> nil
```

This is a problem because it's in violation of the [scope][] specification:

> A scope represents a narrowing of a database query

Furthermore, if we run `Bill.ineligible_for_payment`, we'll run into an error.

```ruby
Bill.ineligible_for_payment

# => raise ArgumentError, "You must only pass a single or collection of #{klass.name} objects to ##{__callee__}."
```

This is because this scope is [excluding][] our updated scope, which is not
returning the correct instances.

Fortunately we can fix this by simply using a sub query.

```diff
--- a/app/models/bill.rb
+++ b/app/models/bill.rb
@@ -2,7 +2,7 @@ class Bill < ApplicationRecord
   has_many :payments, dependent: :destroy

   scope :eligible_for_payment, -> {
-    Bill::EligibleForPayment.all
+    where(id: Bill::EligibleForPayment.ids)
   }
   scope :ineligible_for_payment, -> { excluding(eligible_for_payment) }
 end
```

## Wrapping up

This solution is about trade-offs. If there's a risk that the scope will change
frequently, then it might be better to leverage a database view. However, that
comes with the cost of a slightly less performant query used in the scope. In
our case, we ended up not creating a database view, and instead provided the
data team the query we're using in the scope. This comes with the cost of making
sure we communicate any future changes, or risk data drift.

[scope]: https://api.rubyonrails.org/v7.1.1/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-scope
[to_sql]: https://api.rubyonrails.org/classes/ActiveRecord/Relation.html#method-i-to_sql
[database view]: https://guides.rubyonrails.org/active_record_postgresql.html#database-views
[scenic]: https://github.com/scenic-views/scenic
[excluding]: https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-excluding
