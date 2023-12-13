---
title: Are your polymorphic relationships correctly enforced?
exceprt: Learn how to strike a balance between flexibility and data integrity with a partial index and validations.
categories: ["Ruby on Rails"]
tags: ["PostgreSQL", "Active Record"]
canonical_url: https://thoughtbot.com/blog/rails-polymorphic-uniqueness-constraints
---

My client project uses a [polymorphic][] relationship between several models in
an effort to create a flexible system of associations.

However, I realized that this system was **too** flexible because it did not
enforce the relationships as expected.

[polymorphic]: https://guides.rubyonrails.org/association_basics.html#polymorphic-associations

## Our base

Here’s the domain we’ll be working with in this tutorial. The important thing to
note is that a `product` `has_many :pictures` and an `employee` `has_one
:picture`.

```ruby
class Employee < ApplicationRecord
  has_one :picture, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end
```

## The problem

I've previously written about the [limitations of a has_one relationship][1], and
this is no different. As you can see, it's still possible to associate more than
one `picture` with an `employee`.

```ruby
employee = Employee.last
employee.create_picture
Picture.create(imagable: employee)

Picture.where(imagable: employee).count
# => 2
```

## A naïve solution

In the [previous article][1] we solved this by creating a unique index. Since
we're working with a polymorphic relationship, we'll need to make this index on
the `imageable` columns.

```ruby
class AddContstraintToPictures < ActiveRecord::Migration[7.1]
  def up
    add_index :pictures, [:imageable_type, :imageable_id],
      unique: true,
      name: "by_employee"
  end

  def down
    remove_index :pictures, name: "by_employee"
  end
end
```

Then, we can compliment the unique index by adding a
[validates_uniqueness_of][2] validation.

```diff
--- a/app/models/picture.rb
+++ b/app/models/picture.rb
@@ -1,3 +1,5 @@
 class Picture < ApplicationRecord
   belongs_to :imageable, polymorphic: true
+
+  validates_uniqueness_of :imageable_type, scope: :imageable_id
 end
```

However, this approach is too heavy-handed. Although it prevents an `employee`
from having more than one `picture`, it also prevents a `product` from having
more than one `picture`.

```ruby
product = Product.last
product.pictures.create!

picture = product.pictures.build
picture.valid?
=> false

picture.errors.messages
=> {:imageable_type=>["has already been taken"]}
```

## An improved solution

What we need is a [partial index][]. This allows us to conditionally enforce the
uniqueness constraint. In this case, we want to do this when the `imageable_type
= "Employee"`.

[partial index]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index-label-Creating+a+partial+index

```diff
--- a/db/migrate/20231123105601_add_contstraint_to_pictures.rb
+++ b/db/migrate/20231123105601_add_contstraint_to_pictures.rb
@@ -2,7 +2,8 @@ class AddContstraintToPictures < ActiveRecord::Migration[7.1]
   def up
     add_index :pictures, [:imageable_type, :imageable_id],
       unique: true,
-      name: "by_employee"
+      name: "by_employee",
+      where: "imageable_type = 'Employee'"
   end
```

We can also add this conditional to the [uniqueness validation][2] by using the
`conditional` option.

```diff
--- a/app/models/picture.rb
+++ b/app/models/picture.rb
@@ -1,5 +1,6 @@
 class Picture < ApplicationRecord
   belongs_to :imageable, polymorphic: true

-  validates_uniqueness_of :imageable_type, scope: :imageable_id
+  validates_uniqueness_of :imageable_type, scope: :imageable_id,
+    conditions: -> { where(imageable_type: "Employee") }
 end
```

## Wrapping up

Although this solution enforces our conditional uniqueness constraint in both
the database and application, it's not necessarily the most flexible solution.
If you introduce a new model with `has_one :picture, as: :imageable`, you'll
need to modify the database index.

Instead, you might want to consider just leveraging the [validation][2] at the
application level, knowing that [it's possible duplicate records could still be
added][3].

[1]: https://thoughtbot.com/blog/rails-has-one-limitations
[2]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of
[3]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of-label-Concurrency+and+integrity
