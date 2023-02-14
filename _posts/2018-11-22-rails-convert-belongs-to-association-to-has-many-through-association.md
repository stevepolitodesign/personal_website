---
title: Convert a belongs_to Association to a has_many :through Association in Ruby on Rails
tags: ["Database", "Migrations"]
categories: ["Ruby on Rails"]
resources: [{
    title: "The belongs_to Association API",
    url: "https://guides.rubyonrails.org/association_basics.html#the-belongs-to-association"
},
{
    title: "The has_many :through Association API",
    url: "https://guides.rubyonrails.org/association_basics.html#the-has-many-through-association"   
},{
    title: "Using a model after changing its table",
    url: "https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#class-ActiveRecord::Migration-label-Using+a+model+after+changing+its+table"
}]
date: 2018-11-22
---

I was tasked with converting a `belongs_to` association to a `has_many :through` association. The challenge was that the app was live, and there were existing relationships. I was able to convert the `belongs_to` association to a `has_many :through` association while still maintaining existing relationships by creating a custom migration file, and updating the existing models.

In order to understand how to create this conversion, let's create a sample app.

**If you want to skip ahead to the solution [click here.](#create-join-table)**

## 1. Create a Sample Rails App

Run the following commands in a new terminal window.

```text
rails new association-converter --database=postgresql
cd association-converter/
rails g scaffold Author name:string
rails g scaffold Book name:string author:references
rails db:migrate
```

## 2. Create the belongs_to Association

Update the **Book** and **Author** models so they are associated with a `belongs_to` association.

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end
```

## 3. Seed the database

Install [Faker](https://github.com/stympy/faker) and seed the database with sample data.

1. Add `gem 'faker', '~> 1.9', '>= 1.9.1'` to your `Gemfile`
1. Run `bundle install`
1. Open `seeds.db` and add the following:

   ```ruby
   100.times { |i| Author.create(name: Faker::Name.name) }
   
   Author.all.each { |author| author.books.create(name: Faker::Book.title) }
   ```

1. Seed the database by running `rails db:seed` 5. Open up the **Rails Console** by running `rails c`. Confirm there is data in the database by running the following:

   ```ruby
   2.3.1 :001 > Author.count
   (0.6ms) SELECT COUNT() FROM "authors"
   => 100
   2.3.1 :002 >
   ```

   ```ruby
   2.3.1 :002 > Book.count
   (14.2ms) SELECT COUNT() FROM "books"
   => 100
   2.3.1 :003 >
   ```

   ```ruby
   Book.last.author
   Book Load (64.1ms) SELECT "books"._ FROM "books" ORDER BY "books"."id" DESC LIMIT ? [["LIMIT", 1]]
   Author Load (0.3ms) SELECT "authors"._ FROM "authors" WHERE "authors"."id" = ? LIMIT ? [["id", 100], ["LIMIT", 1]]
   => #<Author id: 100, name: "Shirlee Mayert DDS", created_at: "2018-11-21 22:22:46", updated_at: "2018-11-21 22:22:46">
   ```

1. Open up `schema.rb` to confirm the schema looks similar to the following:

   ```ruby
   ActiveRecord::Schema.define(version: 2018_11_22_151441) do
     # These are extensions that must be enabled in order to support this database
   
     enable_extension "plpgsql"
   
     create_table "authors", force: :cascade do |t|
       t.string "name"
       t.datetime "created_at", null: false
       t.datetime "updated_at", null: false
     end
   
     create_table "books", force: :cascade do |t|
       t.string "name"
       t.bigint "author_id"
       t.datetime "created_at", null: false
       t.datetime "updated_at", null: false
       t.index ["author_id"], name: "index_books_on_author_id"
     end
   
     add_foreign_key "books", "authors"
   end
   ```

At this point we have set up a simple `belongs_to` association. This will be the baseline to understanding how to convert a `belongs_to` association to a `has_many :through` association.

## 4. Create a Join Table<a name="create-join-table"></a>

1. Open a new terminal and run `rails g model BooksAuthors book:references author:references`.

   The new migration file should render something similar to the following:

   ```ruby
   class CreateBooksAuthors < ActiveRecord::Migration[5.2]
     def change
       create_table :books_authors do |t|
         t.references :book, foreign_key: true
         t.references :author, foreign_key: true
       end
     end
   end
   ```

2. Update the migration file to use `def up` and `def down` methods. Specifically, add the following:

   - In the `def up` method use `create_table` to create a new join table.
   - In the `def up` method populate the new join table with the existing relationships.
   - In the `def up` method remove the existing `reference` column.
   - In the `def down` method add a `reference` column.
   - In the `def down` method populate the reference column.
   - In the `def down` method use the `drop_table` method to remove the join table.

   ```ruby
   class CreateBooksAuthors < ActiveRecord::Migration[5.2]
     def up # create join table
       create_table :books_authors do |t|
         t.references :book, foreign_key: true
         t.references :author, foreign_key: true
   
         t.timestamps
       end
       # populate join table with existing data
       puts "populating books_authors"
       Book.all.each do |book|
         puts "#{book.name} is being added to the books_authors table"
         BooksAuthor.create(book_id: book.id, author_id: book.author_id)
         puts "There are #{BooksAuthor.count} books_authors records"
       end
       # remove obsolete column
       puts "removing old association"
       remove_reference :books, :author, foreign_key: true
     end
   
     def down # add reference column back
       add_reference :books, :author, foreign_key: true # Using a model after changing its table # https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#class-ActiveRecord::Migration-label-Using+a+model+after+changing+its+table
       Book.reset_column_information # associate book with author, even though it will just be one.
       BooksAuthor.all.each do |book_author|
         Book.find(book_author.book_id).update_attribute(
           :author_id,
           book_author.author_id,
         )
       end # remove join table
       drop_table :books_authors
     end
   end
   ```

3. Update the database by running `rails db:migrate` in a terminal window.
4. Open `schema.rb` to confirm the schema looks similar to the following:

   ```ruby
   ActiveRecord::Schema.define(version: 2018_11_22_151828) do
     # These are extensions that must be enabled in order to support this database
   
     enable_extension "plpgsql"
   
     create_table "authors", force: :cascade do |t|
       t.string "name"
       t.datetime "created_at", null: false
       t.datetime "updated_at", null: false
     end
   
     create_table "books", force: :cascade do |t|
       t.string "name"
       t.datetime "created_at", null: false
       t.datetime "updated_at", null: false
     end
   
     create_table "books_authors", force: :cascade do |t|
       t.bigint "book_id"
       t.bigint "author_id"
       t.datetime "created_at", null: false
       t.datetime "updated_at", null: false
       t.index ["author_id"], name: "index_books_authors_on_author_id"
       t.index ["book_id"], name: "index_books_authors_on_book_id"
     end
   
     add_foreign_key "books_authors", "authors"
     add_foreign_key "books_authors", "books"
   end
   ```

5. Open the **Rails Console** by running `rails c`. Enter the following to confirm the data was migrated correctly:

   ```ruby
   2.3.1 :001 > BooksAuthor.count
   (0.1ms) SELECT COUNT(\*) FROM "books_authors"
   => 100
   ```

6. Update the existing models.

   - Update `books_author.rb`
     ```ruby
     class BooksAuthor < ApplicationRecord
       belongs_to :book
       belongs_to :author
     end
     ```
   - Update `book.rb`
     ```ruby
     class Book < ApplicationRecord
       has_many :books_authors
       has_many :authors, through: :books_authors, dependent: :destroy
     end
     ```
   - Update `author.rb`
     ```ruby
     class Author < ApplicationRecord
       has_many :books_authors
       has_many :books, through: :books_authors, dependent: :destroy
     end
     ```

7. Open a terminal window and run `rails c`. Then run the following:

   ```ruby
   2.3.1 :003 > Book.last.authors
   Book Load (0.4ms) SELECT "books"._ FROM "books" ORDER BY "books"."id" DESC LIMIT $1 [["LIMIT", 1]]
   Author Load (0.6ms) SELECT "authors"._ FROM "authors" INNER JOIN "books_authors" ON "authors"."id" = "books_authors"."author_id" WHERE "books_authors"."book_id" = $1 LIMIT $2 [["book_id", 100], ["LIMIT", 11]]
   => #<ActiveRecord::Associations::CollectionProxy [#<Author id: 100, name: "Claude O'Keefe", created_at: "2018-11-22 15:16:51", updated_at: "2018-11-22 15:16:51">]>
   ```

## 5. Rolling Back The Conversion

If you need to rollback the conversion, follow these steps.

1. Open up a terminal window and run `rails db:rollback`.
1. The `schema.rb` should look similar to the following:

   ```ruby
   ActiveRecord::Schema.define(version: 2018_11_22_151441) do
     # These are extensions that must be enabled in order to support this database
   
     enable_extension "plpgsql"
   
     create_table "authors", force: :cascade do |t|
       t.string "name"
       t.datetime "created_at", null: false
       t.datetime "updated_at", null: false
     end
   
     create_table "books", force: :cascade do |t|
       t.string "name"
       t.datetime "created_at", null: false
       t.datetime "updated_at", null: false
       t.bigint "author_id"
       t.index ["author_id"], name: "index_books_on_author_id"
     end
   
     add_foreign_key "books", "authors"
   end
   ```

1. Open up a terminal and run `rails c`. Then run the following:

   ````ruby
   2.3.1 :001 > Book.last
   Book Load (0.5ms) SELECT "books".\* FROM "books" ORDER BY "books"."id" DESC LIMIT $1 [["LIMIT", 1]]
   => #<Book id: 100, name: "To Sail Beyond the Sunset", created_at: "2018-11-22 15:16:52", updated_at: "2018-11-22 15:26:07", author_id: 100>
   ```4. Finally, make sure to remove the **join table** model, and revert the **Book** and **Author** models back to a **belongs_to** association.
   ````
