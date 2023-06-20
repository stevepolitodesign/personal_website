---
title: "Are you absolutely sure your `has_one` association really has one association?"
excerpt: "Learn about an unexpected limitation with this API and how to combat it universally."
categories: ["Ruby on Rails"]
canonical_url: https://thoughtbot.com/blog/rails-has-one-limitations
---

The Rails [has_one][1] API has an unexpected limitation: It does not prevent
**multiple** records from being associated to the parent record.

Take this simple example straight from the [Rails Guides][1]. We have a
`supplier` that `has_one` `account`. Seems simple enough, but let's take a
closer look.

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end

class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.belongs_to :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

The API provides [association methods][2] including
[create_other(attributes={})][3]. This allows us to create an `account`
off of a `supplier`. If we do this more than once, we'll raise an error.

```ruby
supplier = Supplier.create!
supplier.create_account(name: "first")

Account.count
# => 1

supplier.create_account(name: "second")
# => Failed to remove the existing associated account. The record failed to save after its foreign key was set to nil. (ActiveRecord::RecordNotSaved)
```

At first glance, you might think that the `ActiveRecord::RecordNotSaved`
error means that our `has_one` association is working as expected, and that
it prevented another `account` record from being created. Unfortunately, what's
really happening is that we couldn't `nullify` the `supplier_id` on the existing
`account`, but we were still able to create a new `account` that is associated
with the `supplier`. This leaves us with an orphaned `account` record.

```ruby
Account.count # <- We still created another record ‼️
# => 2

Account.last.name
# => "second"

Account.last.supplier == supplier
# => true

supplier.account.name
# => "first"
```

<aside class="info">
Prior to Rails <code>7.0.5</code>, calling <code>create_other</code> multiple
times would have resulted in additional records being created. Here's the <a
href="https://github.com/rails/rails/pull/46386">pull request</a> that improved
this behavior by ensuring only one record is ever created.
</aside>

As we can see, the `account` is associated with the `supplier`, but the
`supplier` is still associated with the original `account`. Rails attempted to
`nullify` the `supplier_id` on the first `account` in an effort to maintain the
`has_one` relationship, but our database constraint prevented it from doing so.
What we need to do is add an option to [delete the association][4].

```ruby
class Supplier < ApplicationRecord
  has_one :account, dependent: :destroy
end
```

Now Rails will know to delete the original `account` once the new `account` has
been created.

```ruby
supplier = Supplier.create!
supplier.create_account(name: "first")
supplier.create_account(name: "second")

Account.count
# => 1

supplier.account.name
# => "second"
```

However, there's a subtle yet important limitation with our current
implementation. We can still associate more than one `account` with the same
`supplier` if we simply bypass the generated [association method][2]!

```ruby
supplier = Supplier.create!
supplier.create_account(name: "first")

Account.create(name: "second", supplier: supplier) # <- We can still create another record ‼️
# => #<Account>

supplier.account.name
# => "second"
```

As you can see, there's nothing preventing us from creating another `account`
record if we avoid using the `create_account` method. This is because we're not
enforcing this constraint at the database. The [has_one][1] API simply provides
some convenience methods, but it does not actually enforce the relationship.

To fix this, we need to add a uniqueness constraint in the database. This is
briefly mentioned in the [Guides][1].

> Depending on the use case, you might also need to create a unique index and/or
> a foreign key constraint on the supplier column for the accounts table. In
> this case, the column definition might look like this:

```diff
class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name
-     t.belongs_to :supplier, null: false, foreign_key: true
+     t.belongs_to :supplier, null: false, index: { unique: true }, foreign_key: true

      t.timestamps
    end
  end
end
```

Now, if we try to create another association without the [association
methods][2], we'll raise an error.

```ruby
supplier = Supplier.create!
supplier.create_account(name: "first")

Account.create(name: "second", supplier: supplier) # <- We can no longer create another record ✅
# => ActiveRecord::RecordNotUnique

Account.count
# => 1
```

Additionally, we'll also raise an error if we use the [association methods][2].
This is valuable since it's possible for an application to make this call in
multiple places, such as background jobs or tasks.

```ruby
supplier = Supplier.create!
supplier.create_account(name: "first")

supplier.create_account(name: "second") # <- We can no longer create another record ✅
# => ActiveRecord::RecordNotUnique

Account.count
# => 1
```

So, the next time you're thinking of implementing a `has_one` relationship,
consider what we just reviewed. Rails itself does not guarantee a 1:1
relationship. That responsibility is on you. Pushing that constraint into the
database provides a safety net against this often overlooked pitfall.

[1]: https://guides.rubyonrails.org/association_basics.html#the-has-one-association
[2]: https://guides.rubyonrails.org/association_basics.html#has-one-association-reference
[3]: https://api.rubyonrails.org/v7.0.5/classes/ActiveRecord/Associations/ClassMethods.html#module-ActiveRecord::Associations::ClassMethods-label-Auto-generated+methods
[4]: https://api.rubyonrails.org/v7.0.5/classes/ActiveRecord/Associations/ClassMethods.html#module-ActiveRecord::Associations::ClassMethods-label-Deleting+from+associations
