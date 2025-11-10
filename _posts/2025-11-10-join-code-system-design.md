---
title: How to design a join code system
excerpt: Learn the ins and outs of building a game-based join code feature.
category: ["Ruby on Rails"]
tags: ["Web Development", "Design"]
canonical_url: https://thoughtbot.com/blog/join-code-system-design
---

I was recently on a project that needed a "join code/game pin" feature similar to those
found in multiplayer quiz games.

![A low-fidelity mock-up of a screen where you enter a join code to join a game.](https://images.thoughtbot.com/9iz42ci8cdbr2vxshg24tgm0jx89_Untitled-2025-10-31-0942.png)

I naively thought this could be achieved in a matter of hours, but soon realized
there was a lot of nuance. This is the article I wish existed when I started
working on this feature.

## Understanding the requirements

A join code needs to be short, easy to type, as well as easy to read or even say
aloud (in cases where the user cannot see the code). Because of this, APIs like
[`generate_token_for`][generate_token_for] weren't going to work, because
they're not meant to be typed, or viewed. They're meant to be clicked.

Because of this, most join codes are 6 characters long, consisting of numbers,
letters, or a combination of the two.

## Naive implementation

Knowing this, I figured I would just generate a random 6 character digit and
call it a day.

```ruby
join_code = SecureRandom.random_number(1000000).to_s.rjust(6, "0")

# => "891907"

# Create game
Game.create!(join_code:)

# Find game
Game.find_by(join_code: params[:join_code])
```

This technique will yield 1,000,000 (10 digits with 6 possible positions = 10^6)
possible combinations, which seems like it would be plenty.

But then I got to thinking:

-   What happens if the feature is a massive success, and we eventually exhaust
    all of the possible 1,000,000 combinations?
-   How likely are collisions if we can't recycle join codes?

## Understanding collision probability

In order to answer these questions, I found it easier to break the problem down
into something simpler.

Let's assume join codes are 1 character in length, and can only be a digit (0-9).

This means there's always a 10% chance of randomly generating any number. But,
once a value has been used, the probability of colliding increases linearly.

| Join Codes in DB (before) | Chance Generated Join Code Exists |
| ------------------------- | --------------------------------- |
| 0                         | 0.0%                              |
| 1                         | 10.0%                             |
| 2                         | 20.0%                             |
| 3                         | 30.0%                             |
| 4                         | 40.0%                             |
| 5                         | 50.0%                             |
| 6                         | 60.0%                             |
| 7                         | 70.0%                             |
| 8                         | 80.0%                             |
| 9                         | 90.0%                             |
| 10                        | 100.0%                            |

This means that once we have 500,000 rows in the database, there will be a 50%
chance of a collision when generating the next join code. As each new row is
added, the collision rate will increase.

This is a problem if we can't recycle join codes, because we'll need to handle
these collisions on each attempt, which could result in an infinite loop.

## Alphanumeric implementation

After realizing that 1,000,000 combinations may not be enough, I figured I'd go
with an alphanumeric approach, since that would result in more combinations, and
more time until a 50% collision rate.

```ruby
join_code = SecureRandom.alphanumeric(6).upcase

# => "TOAJR7"

# Create game
Game.create!(join_code:)

# Find game
Game.find_by(join_code: params[:join_code])
```

Now there are 2,176,782,336 (10 digits + 26 letters with 6 possible positions =
36^6) possible combinations.

## UX considerations with an alphanumeric join code

I thought the alphanumeric approach would be easy, until I realized there are
some UX "gotchas".

The first "gotcha" is that some numbers look like capitalized letters.

-   0 ↔ O
-   1 ↔ I
-   2 ↔ Z
-   5 ↔ S
-   8 ↔ B
-   U ↔ V

The second "gotcha" is there's a chance the randomly generated join code will
contain a profanity or two.

Tools like [Sqids Ruby][sqids-ruby] account for both of these concerns.

The third "gotcha" is normalization. It's a better UX not to have to capitalize
individual characters when entering a join code. But this means you'll want
to normalize the value when making the query.

```ruby
class Game < ActiveRecord::Base
  normalizes :join_code, with: -> join_code { join_code.strip.upcase }
end

join_code = Game.normalize_value_for(join_code: params[:join_code])
Game.find_by(join_code:)
```

You'll also want to make the value appears capitalized.

```html
<style>
    #join_code {
        text-transform: uppercase;
    }
</style>

<input type="text" id="join_code" name="join_code" />
```

## Scoping to time, not space

We can avoid the collision and UX concerns by limiting **when** a join code
can be used.

Instead of indexing on the join code alone, we can scope it to another column.
In most cases, using a join code should be limited to a point of time, since
games are temporary.

The simplest way to do this would be with an `active` boolean column. Here's
what that schema might look like:

```ruby
class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :join_code
      t.boolean :active, default: false, null: false

      t.timestamps
    end

    add_index :games, :join_code, unique: true, where: "active = true AND join_code IS NOT NULL"

    add_check_constraint :games, "join_code IS NOT NULL OR active = false",
      name: "active_games_require_join_code"
  end
end
```

This would allow join codes to be recycled, while ensuring they're unique
across all "active" games.

```ruby
# Create game
Game.create!

# Find an active game
Game.active.find_by(join_code: params[:join_code])
```

This means the probability of a collision would eclipse 50% when there are
500,000 **active** games, which is far less of a concern. We can actually use
our naive number-based implementation from the beginning now that we understand
how to scope the join code.

Here's a complete example:

```ruby
class Game < ApplicationRecord
  JOIN_CODE_REGEX = /\A\d{6}\z/

  validates :join_code, presence: true, if: :active?
  validates :join_code, uniqueness:  {
    scope: :active,
    conditions: -> { where(active: true) }
  }
  validates :join_code, format: {
    with: JOIN_CODE_REGEX
  }, if: :active?

  before_validation :set_join_code, unless: :join_code?

  scope :active, -> { where(active: true) }

  private

  def set_join_code
    max_attempts = ENV.fetch("JOIN_CODE_GENERATION_MAX_ATTEMPTS")

    max_attempts.times do
      self.join_code = generate_join_code

      next if @existing_game = Game.active.exists?(join_code:)
    end

    raise "Failed to generate unique join_code after #{max_attempts} attempts" if @existing_game
  end

  def generate_join_code
    SecureRandom.random_number(1000000).to_s.rjust(6, "0")
  end
end
```

## Wrapping up

Let's circle back to the original requirements:

> A join code needs to be short, easy to type, as well as easy to read or even
> say aloud (in cases where the user cannot see the code).

By sticking with digits only, our complete example accounts for all of these
requirements. It also provides a better UX because users won't need to toggle
between their number keys and character keys, or concern themselves with
capitalization. It also alleviates us from needing to account for profanities or
characters that look alike, as well as normalization.

It turns out, our naive implementation from the beginning was mostly right, but
we needed to take the scenic route to come to that conclusion.

[generate_token_for]: https://api.rubyonrails.org/classes/ActiveRecord/TokenFor.html#method-i-generate_token_for
[sqids-ruby]: https://github.com/sqids/sqids-ruby
