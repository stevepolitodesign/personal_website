---
title: Configure GitHub Actions to work with rspec-rails
excerpt: 'The next release of Rails will ship with a CI template that will "work out of the box"... unless you''re using RSpec.'
categories: ["Ruby on Rails"]
tags: ["RSpec"]
canonical_url: https://thoughtbot.com/blog/rspec-rails-github-actions-configuration
---

The next release of Rails will ship with a [CI template][ci] which among other
things, will run the [Rails test suite][minitest]. I figured this would be a
useful addition for the [next release of Suspenders][suspenders], so I lifted
the template and modified it to work with [rspec-rails][rspec].

It was a mostly straightforward process, but I wanted to highlight some of the
issues I ran into.

## Our Base

Below is a distilled Gemfile. It assumes we ran `rails new` with the
`--skip-test` flag, since we're choosing to use [rspec-rails][rspec].

```sh
rails new <app_name> \
--skip-test \
-d=postgresql
```

Because we skipped scaffolding the test files, we'll need to add
[capybara][capybara] and [selenium-webdriver][selenium] too.

```ruby
# Gemfile

group :development, :test do
  gem "rspec-rails", "~> 6.1.0"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
```

Then we can run RSpec's installation script to generate the necessary files.

```
bin/rails g rspec:install
```

Finally, let's create a simple [system test][system] so we have something to use
in CI.

```ruby
require 'rails_helper'

RSpec.describe "Homepage", type: :system do
  it "passes" do
    visit root_path

    expect(page).to have_content "Welcome!"
  end

  it "fails (and takes a screenshot)" do
    visit root_path

    expect(page).to_not have_content "Welcome!"
  end
end
```

You'll note we have a test that's designed to fail. This is deliberate, since we
want to ensure failure screenshots are captured in CI.

## Building the CI script

Since it's likely a future commit will [remove the test job][test job] from the
CI template when `rails new` is passed the `--skip-test` flag, we can't just
count on it existing. For now, we can just copy the [CI template][ci template]
locally into `.github/workflows/ci.yml`, and adjust it accordingly.

### Run specs not tests

The first thing we'll want to do is update the script to run `spec` and not
`test test:system`, since those commands do not exist.

```
--- a/.github/workflows/ci.yml
+++ b/.github/workflows/ci.yml
@@ -79,7 +79,7 @@ jobs:
         env:
           RAILS_ENV: test
           # REDIS_URL: redis://localhost:6379/0
-        run: bin/rails db:setup test test:system
+        run: bin/rails db:setup spec

       - name: Keep screenshots from failed system tests
         uses: actions/upload-artifact@v4
```

### Keep parity with ApplicationSystemTestCase

Next, we'll want to configure RSpec to use `:headless_chrome` by default, since
this is the [new default][headless] in Rails. This is important because our CI
script will error out, since RSpec defaults to `:selenium`. However, a future
release of [rspec-rails][rspec] will [change the default][rspec-headless] to
keep parity with Rails.

```ruby
# spec/support/driver.rb

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  end
end
```

I also felt it was important to keep parity with the `screen_size` too, but that
part is optional.

## Save screenshots of failed system tests

Rails automatically takes a screenshot when a system test fails. We can test
this by running our failing test locally.

```
Failures:

  1) Homepage fails (and takes a screenshot)
     Failure/Error: expect(page).to_not have_content "Welcome!"
       expected not to find text "Welcome!" in "Welcome!"

     [Screenshot Image]: /tmp/capybara/failures_r_spec_example_groups_homepage_fails_-and_takes_a_screenshot-_632.png


     # ./spec/system/homepage_spec.rb:13:in `block (2 levels) in <top (required)>'

Finished in 9.43 seconds (files took 1.02 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/system/homepage_spec.rb:10 # Homepage fails (and takes a screenshot)
```

However, the path it saves to differs from the path set in the CI template. If
the path is incorrect, the [screenshots][] won't be available in CI. We can
adjust this as follows:

```diff
--- a/.github/workflows/ci.yml
+++ b/.github/workflows/ci.yml
@@ -86,5 +86,5 @@ jobs:
         if: failure()
         with:
           name: screenshots
-          path: ${{ github.workspace }}/tmp/screenshots
+          path: ${{ github.workspace }}/tmp/capybara
           if-no-files-found: ignore
```

## Wrapping up

Below is what the final test portion of the modified CI script looks like.
Fortunately, the [next release of Suspenders][suspenders] will generate this
file for us, but I'm sharing it here for added transparency.

```yml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: --health-cmd="pg_isready" --health-interval=10s --health-timeout=5s --health-retries=3

    steps:
      - name: Install packages
        run: sudo apt-get update && sudo apt-get install --no-install-recommends -y google-chrome-stable curl libjemalloc2 libvips postgresql-client libpq-dev

      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: Run tests
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432
        run: bin/rails db:setup spec

      - name: Keep screenshots from failed system tests
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: screenshots
          path: ${{ github.workspace }}/tmp/capybara
          if-no-files-found: ignore
```

[ci]: https://github.com/rails/rails/pull/50508
[minitest]: https://guides.rubyonrails.org/testing.html
[suspenders]: https://github.com/thoughtbot/suspenders/pull/1135
[rspec]: https://github.com/rspec/rspec-rails
[capybara]: https://github.com/teamcapybara/capybara
[selenium]: https://rubygems.org/gems/selenium-webdriver
[system]: https://rspec.info/features/6-1/rspec-rails/system-specs/
[test job]: https://github.com/rails/rails/pull/51289
[ci template]: https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/app/templates/github/ci.yml.tt
[headless]: https://github.com/rails/rails/pull/50512
[rspec-headless]: https://github.com/rspec/rspec-rails/pull/2746
[screenshots]: https://github.com/actions/upload-artifact?tab=readme-ov-file#where-does-the-upload-go
