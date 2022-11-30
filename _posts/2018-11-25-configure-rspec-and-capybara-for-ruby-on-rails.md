---
title: Configure RSpec and Capybara with Ruby on Rails
tags: ["Testing", "RSpec", "Capybara"]
categories: ["Ruby on Rails"]
resources: [{
    title: "Source Code",
    url: "https://github.com/stevepolitodesign/rails-rspec-capybara-configuration"
},{
    title: "RSpec Rails",
    url: "https://github.com/rspec/rspec-rails"
},
{
    title: "Capybara",
    url: "https://github.com/teamcapybara/capybara"
},
{
    title: "Factory Bot Rails",
    url: "https://github.com/thoughtbot/factory_bot_rails"
},
{
    title: "Database Cleaner",
    url: "https://github.com/DatabaseCleaner/database_cleaner"
},{
    title: "RSpec Rails Examples",
    url: "https://github.com/eliotsykes/rspec-rails-examples"
}]
date: 2018-11-25
---

In this tutorial I'm going to show you how to configure your Rails app to use **RSpec** and **Capaybara**. In addition, we will also install and configure **Factory Bot Rails** and **Database Cleaner**, since these Gems help with a better testing experience.

`youtube:https://www.youtube.com/embed/XZkVRkNUFG0`

## 1. Create a New App and Skip Tests

> Since we'll be using **rspec-rails** as the test framework, we need to skip the default Rails test suite.

1. Open up a new terminal and create a new Rails app. Be sure to pass the `-T` flag. This will skip the [default test suite](https://guides.rubyonrails.org/testing.html#rails-sets-up-for-testing-from-the-word-go)

```
rails new rspec-demo -d=postgresql -T
cd rspec-demo/
```

## 2. Install and Configure RSpec Rails

> **rspec-rails** is a testing framework for Rails 3.x, 4.x and 5.x. rspec-rails extends Rails' built-in testing framework to support rspec
examples for requests, controllers, models, views, helpers, mailers and
routing.
>
> **TLDR: rspec-rails is a popular alternative to the default Rails test suite.**

1. Add `gem 'rspec-rails'` to your `Gemfile` in the `:development, :test` `group`.

```ruby{3}
group :development, :test do
    ...
    gem 'rspec-rails', '~> 3.8', '>= 3.8.2'
end
```

2. In the terminal window, run `bundle install`
3. In the terminal window, run `rails generate rspec:install` per [rspec-rails instructions](https://github.com/rspec/rspec-rails#installation)


## 3. Install and Configure Factory Bot Rails

> **factory_bot** is a fixtures replacement with a straightforward definition syntax, support for multiple build strategies (saved instances, unsaved instances, attribute hashes, and stubbed objects), and support for multiple factories for the same class (user, admin_user, and so on), including factory inheritance.
> 
> **TLDR: factory_bot makes it easy to create sample data to test against**

1. Add `gem 'factory_bot_rails'` to your `Gemfile` in the `:development, :test` `group`.

```ruby{4}
group :development, :test do
  ...
  gem 'rspec-rails', '~> 3.8', '>= 3.8.2'
  gem 'factory_bot_rails', '~> 5.1'
end
```

2. In the terminal window, run `bundle install`
3. Create a new directory at `mkdir spec/factories/` by running `mkdir spec/factories` in the terminal window. This is required by [factory\_bot\_rails](https://github.com/thoughtbot/factory_bot_rails#automatic-factory-definition-loading)
4. Create a new directory at `spec/support/` by running `mkdir spec/support` in the terminal window
5. Create `factory_bot.rb` in `spec/support` by running `touch spec/support/factory_bot.rb` in the terminal window
6. Open `spec/support/factory_bot.rb` and add the following:

```ruby
RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
end 
```

7. Open `spec/rails_helper.rb` and uncomment `Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }`.


## 4. Install and Configure Capybara

> **Capybara** is a library written in the Ruby programming language which makes it easy to simulate how a user interacts with your application.

1. Add `gem 'capybara'` to your `Gemfile` in the `:development, :test` `group`.

```ruby{5}
group :development, :test do
  ...
  gem 'rspec-rails', '~> 3.8', '>= 3.8.2'
  gem 'factory_bot_rails', '~> 5.1'
  gem 'capybara', '~> 3.29'
end
```

2. In the terminal window, run `bundle install`
3. Create `capybara.rb` in `spec/support` by running `touch spec/support/capybara.rb` in the terminal window
4. Open `spec/support/capybara.rb` and add the following:

```ruby
require 'capybara/rspec'
```

## 5. Install and Configure Database Cleaner

> **Database Cleaner** is used to ensure a clean state for testing.

1. Add `gem 'database_cleaner'` to your `Gemfile` in the `:test` `group`.

```ruby{2}
group :test do
  gem 'database_cleaner', '~> 1.7'
end
```

2. In the terminal window, run `bundle install`
3. Open `spec/support/capybara.rb` and add the following:

```ruby{3-46}
require 'capybara/rspec'

RSpec.configure do |config|

    config.use_transactional_fixtures = false
  
    config.before(:suite) do
      if config.use_transactional_fixtures?
        raise(<<-MSG)
          Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
          (or set it to false) to prevent uncommitted transactions being used in
          JavaScript-dependent specs.
  
          During testing, the app-under-test that the browser driver connects to
          uses a different database connection to the database connection used by
          the spec. The app's database connection would not be able to access
          uncommitted transaction data setup over the spec's database connection.
        MSG
      end
      DatabaseCleaner.clean_with(:truncation)
    end
  
    config.before(:each) do
      DatabaseCleaner.strategy = :transaction
    end
  
    config.before(:each, type: :feature) do
      # :rack_test driver's Rack app under test shares database connection
      # with the specs, so continue to use transaction strategy for speed.
      driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test
  
      unless driver_shares_db_connection_with_specs
        # Driver is probably for an external browser with an app
        # under test that does *not* share a database connection with the
        # specs, so use truncation strategy.
        DatabaseCleaner.strategy = :truncation
      end
    end
  
    config.before(:each) do
      DatabaseCleaner.start
    end
  
    config.append_after(:each) do
      DatabaseCleaner.clean
    end
  
  end
```

4. Comment out `config.use_transactional_fixtures = true` from `spec/rails_helper.rb`

## 6. Create Our First Test (Optional)

Now that our app's test suite is configured with RSpec, Capybara, Factory Bot Rails and Database Cleaner, let's write some tests to ensure everything is working.

1. In the terminal window, run `rails g model post title body:text` to generate a new `model`.
2. In the terminal window, run `rails db:migrate` to migrate the database. This should have generated `spec/models/post_spec.rb` and `spec/models/post_spec.rb`.
3. Update `spec/models/post_spec.rb` with the following code:

```ruby{2-8}
RSpec.describe Post, type: :model do
  describe "validations" do
    let(:post) { FactoryBot.build(:post) }
    it "should have a title" do
      post.title = nil
      expect(post).to_not be_valid
    end
  end
end
```

4. Run `rspec`. The test should fail.

```bash
F

Failures:

  1) Post validations should have a title
     Failure/Error: expect(post).to_not be_valid
       expected #<Post id: nil, title: nil, body: "MyText", created_at: nil, updated_at: nil> not to be valid
     # ./spec/models/post_spec.rb:8:in `block (3 levels) in <top (required)>'

Finished in 0.16554 seconds (files took 4.71 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/models/post_spec.rb:6 # Post validations should have a title
```

5. Open `app/models/post.rb` and add the following validation:

```ruby{2}
class Post < ApplicationRecord
  validates :title, presence: true
end
```

6. Run `rspec`. The test should pass.

```bash
.

Finished in 0.10767 seconds (files took 1.03 seconds to load)
1 example, 0 failures
```

7. This was just an exercise to ensure the test suite is running correctly. For more examples on how to configure your tests, I recommend looking at [RSpec Rails Examples](https://github.com/eliotsykes/rspec-rails-examples) and [Better Specs](http://www.betterspecs.org/)