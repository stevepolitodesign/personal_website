---
title: "Inspecting Ruby's inspect method"
excerpt: "Because 0x0000000103f70c98 never helped anyone."
categories: ["Ruby"]
canonical_url: https://thoughtbot.com/blog/ruby-inspect-tutorial
---

If you've ever worked with a class in Ruby's [Core
Library](https://ruby-doc.org/3.2.2/) or [Rails](https://api.rubyonrails.org),
you might not realize that special care was taken to print useful information
when used in the context of an IRB session. Take
[Time](https://ruby-doc.org/3.2.2/Time.html) for example.

```ruby
Time.new
# => 2023-06-09 15:10:59.033028 -0400
```

Compare this output to the output of a user defined class.

```ruby
class Person
  attr_reader :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end
end

Person.new("Ralph", 20)
# => #<Person:0x0000000103f70c98 @age=20, @name="Ralph">
```

Although we still print something to the console, it could be improved by
overriding the
[inspect](https://ruby-doc.org/3.2.2/Object.html#method-i-inspect) method.

```ruby
class Person
  attr_reader :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  def inspect
    { name:, age: } # tempting, but doesn't adhere to convention...keep reading!
  end
end

Person.new("Ralph", 20)
# => {:name=>"Ralph", :age=>20}
```

Now instead of printing the class name and memory address, we just print a
`Hash` with the `name` and `age`. This may seem like an improvement, but it
actually violates the specification for the
[inspect](https://ruby-doc.org/3.2.2/Object.html#method-i-inspect) method.

> User defined classes should override this method to provide a better
> representation of obj. > **When overriding this method, it should return a
> string whose encoding is compatible with the default external encoding.**

If we call `inspect` on our `Person` instance, we'll see we're not returning a
`String`, but a `Hash`.

```ruby
Person.new("Ralph", 20).inspect
# => {:name=>"Ralph", :age=>20}
Person.new("Ralph", 20).inspect.class
# => Hash
```

We can use this opportunity to modify our `inspect` method by not only ensuring
it returns a `String`, but also adding back the class name to make it clear
what we're working with. This is a common convention. Here's an [example from
Rails](https://github.com/rails/rails/blob/fdad62b23079ce1b90763cb5fa59321e7ac8b581/actiontext/lib/action_text/attachment.rb#L129-L131).

```ruby
class Person
  attr_reader :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  def inspect
   "#<#{self.class.name} @name=#{name.inspect} @age=#{age.inspect}>"
  end
end

Person.new("Ralph", 20)
# => #<Person @name="Ralph" @age=20>
Person.new("Ralph", 20).inspect
# => "#<Person @name=\"Ralph\" @age=20>"
```

Now if we call `inspect` we'll return a `String` in accordance to the
specification.

You'll also note that we call `inspect` on each attribute, which ensures the
value as a whole is returned as expected.

If we did not do this, the `name` attribute would render without quotation
marks. This is an issue because it makes it look like the `name` is a `Ralph`
class, rather than a `String`.

```ruby
class Person
  attr_reader :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  def inspect
   "#<#{self.class.name} @name=#{name} @age=#{age}>"
  end
end

Person.new("Ralph", 20)
# => #<Person @name="Ralph" @age=20>
Person.new("Ralph", 20).inspect
# => "#<Person @name=Ralph @age=20>" # <- Note the missing quotation marks on Ralph
```

<aside class="info">
  <p><strong>A note on puts</strong></p>
  <p>The output for overriding <strong>inspect</strong> is shown when you create an object, invoke <strong>p</strong> or <strong>pp</strong> on an object, or explicitly call <strong>inspect</strong>. The <strong>puts</strong> command invokes <strong>to_s</strong> on the object, not <strong>inspect</strong>.</p>
  <p>If you use <strong>puts</strong>, remember to call <strong>inspect</strong> as well.</p>
  <p><strong>puts person.inspect</strong></p>
</aside>

## Examples

> With great control comes great <s>responsibility</s> flexibility.

Now that we know we can control what `inspect` displays, let's see what we can
do with it!

### Add a little spice

Only seeing the class name of `Person` isn't super helpful. What about adding a
little to help us debug a problem we're facing right now? Remember, what
`inspect` does can change from day to day based on our needs -- and might not
even need to be committed to the repository.

```ruby
def inspect
  # helpful for debugging, but not needed anywhere else
  is_gmail = email.end_with? "gmail.com"

  "#<#{self.class.name}> name: #{name} is_gmail: #{is_gmail}"
end
```

### Too much spice

Sometimes, we need more than a couple attributes to be displayed, and we don't
want to write an `inspect` with all the properties that we want. We also don't
want to have to maintain this method as we add new class properties. What to do
if _some_ of the attributes make the output overwhelming?

`except` to the rescue!

```ruby
def inspect
  attributes.except(["created_at", "updated_at", "some_long_guid", "a_giant_json"]).to_s
end
```

### Related spice

Many classes are part of `has_x` and `belongs_to` relationships. We can show
some details about those relationships in `inspect`:

```ruby
has_many :favorites

def inspect
  "[other output] favorites: #{favorites.count}"
end
```

or even chain into _their_ `inspect` values:

```ruby
has_many :favorites

def inspect
  "[other output] favorites: #{favorites.map(&:inspect)}"
end
```

### Improving test output

Some tests display the failed object by calling `inspect` on it. For example,
in Minitest,
[assert_predicate](https://docs.seattlerb.org/minitest/Minitest/Assertions.html#method-i-assert_predicate)
will show output like this when the assertion fails:

```text
Person::Test#test_#named?_returns_true_when_the_person_has_a_name [/.../person_test.rb:100]:
Expected #<User id: 25, email: "email@example.com", created_at: "2023-06-09 17:32:48.000000000 +0000", updated_at: "2023-06-09 17:32:48.000000000 +0000", emergency_phone_number: nil, some_id: "418a8ebd-a784-4e79-90ed-3b7df650d421", favorite_sandwich: nil, first_name: nil, last_name: nil, date_of_birth: "2002-06-09", github_url: nil> to be named?.
```

If we define a `Person#inspect`

```ruby
def inspect
  "#{self.class.name}: id=#{id} email=#{email}"
end
```

the test failure becomes much more readable:

```text
Person::Test#test_#named?_returns_true_when_the_person_has_a_name [/.../person_test.rb:100]:
Expected User: id=25 email=email@example.com to be named?.
```

### Formatting

Sometimes the truth <s>is out there</s> can be noisy. Here's another example of
simplifying the output.

```ruby
module Prefixes
  module Out
    module Of
      module Control
        class SomeClass
          def inspect
            self.class.name.gsub(/Prefixes::Out::Of::Control::/, "").to_s
          end
        end
      end
    end
  end
end

# Before
Prefixes::Out::Of::Control::SomeClass.new
# <Prefixes::Out::Of::Control::SomeClass:0x000000010dbd7ca8>

# After
Prefixes::Out::Of::Control::SomeClass.new
# <SomeClass>
```

### Providing a default for subclasses

Another helpful thing we can do is override `inspect` in a higher level object
so we don't have to do it everywhere.

Say we have a bunch of classes that derive from `ApplicationModel`:

```ruby
class ApplicationModel
  def inspect
    "#{self.class.name}: attributes=#{attributes.inspect}>"
  end
end

class SomeClass < ApplicationModel
end

SomeClass.new
# => SomeClass: attributes={}
```

Any subclass that needs to override the implementation can, but with one tiny
block of code on the superclass, we can greatly improve our developer life.
