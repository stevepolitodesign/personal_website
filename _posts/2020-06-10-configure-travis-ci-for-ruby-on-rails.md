---
title: "Configure Travis CI for Ruby on Rails"
date: "2020-06-10"
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/rails-travis-ci-example",
    },
    { title: "Travis CI Configuration", url: "https://config.travis-ci.com/" },
    {
      title: "Travis CI Job Lifecycle",
      url: "https://docs.travis-ci.com/user/job-lifecycle/",
    },
  ]
---

In this tutorial I am going to show you how to configure Travis CI to run your Rails' test suite and system tests everytime you push a new change to your repository.

## Create a Simple Rail Application

First we'll need to create simple Rail application. Open up your terminal and run the following commands.

1. `$ rails new rails-travis-ci-example -d=postgresql`
2. `$ rails db:create`
3. `$ rails g scaffold Post title body:text`

- This step will automatically generate tests and system tests.

3. `$ rails db:migrate`

## Configure Rails Application to run System Tests in Travis CI

Rails is configured by default to run [system tests](https://guides.rubyonrails.org/testing.html#system-testing) in Google Chrome. However, I ran into an issue with Travis CI when it came to running system tests using the default configuration. My solution was to update `test/application_system_test_case.rb` by declearing `:headless_chrome` instead of the default `:chrome` setting.

1. Edit `test/application_system_test_case.rb`

   ```ruby
   # test/application_system_test_case.rb
   
   require "test_helper"
   
   class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
     # ℹ️ Use headless_chrome
     driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
   end
   ```

2. Run the test suite locally to ensure it works and passes.

   ```sh
   $ rails test
   $ rails test:system
   ```

## Configure Travis CI to run the Rails Test Suite and System Tests

Next we need to create a `.travis.yml` file in order for Travis CI to know how to build our application.

1. Creat a `.travis.yml` file and add the following:

   ```yml
   language: ruby
   cache:
     - bundler
     - yarn
   services:
     - postgresql
   before_install:
     - nvm install --lts
   before_script:
     - bundle install --jobs=3 --retry=3
     - yarn
     - bundle exec rake db:create
     - bundle exec rake db:schema:load
   script:
     - bundle exec rake test
     - bundle exec rake test:system
   ```

   | Key                                                       | Description                                                                                                                                                                                                                                                                                                                                |
   | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
   | [os](https://config.travis-ci.com/ref/os)                 | Sets the build's operating system. Note that we did **not** add an `os` key, and are using the [default environment](https://docs.travis-ci.com/user/reference/xenial/)                                                                                                                                                                    |
   | [language](https://config.travis-ci.com/ref/language)     | Selects the language support used for the build. We select `ruby` since this is a Rails project                                                                                                                                                                                                                                            |
   | [cache](https://config.travis-ci.com/ref/job/cache)       | Activates caching content that does not often change in order to speed up the build process. We add `bundler` and `yarn` since Rails uses [bundler](https://bundler.io/) and [yarn](https://yarnpkg.com/) to managage dependencies.                                                                                                        |
   | [services](https://config.travis-ci.com/ref/job/services) | Services to set up and start. We add `postgresql` since our database is postgresql. You could also add `redis`.                                                                                                                                                                                                                            |
   | [before_install](https://config.travis-ci.com/)           | Scripts to run before the install stage. We add `nvm install --lts` to use the latest stable version of Node. This will be needed when we run `yarn` later.                                                                                                                                                                                |
   | [before_script](https://config.travis-ci.com/)            | Scripts to run before the script stage. This sets up our Rails application. Note that I do not seed the database, since we only care about the test environment. I run `bundle install --jobs=3 --retry=3` instead of `bundle` becuase that's what the [documentation](https://docs.travis-ci.com/user/languages/ruby#bundler) recommends. |
   | [script](https://config.travis-ci.com/)                   | Scripts to run at the script stage. In our case, we just run our tests.                                                                                                                                                                                                                                                                    |

2. Log into Travis CI and navigate to `https://travis-ci.org/account/repositories`.
3. Search for your repository, and it enabled. If your repository doesn't appear click the **Sync account** button.

   ![Enable repository on Travis CI](/assets/images/posts/configure-travis-ci-for-ruby-on-rails/1.1.png)

4. Navigate to your project and trigger a build. Alternatively, make a new commit and push to GitHub to trigger a new build.

   ![Trigger a build in Travis CI](/assets/images/posts/configure-travis-ci-for-ruby-on-rails/1.2.png)

5. If you're using Heroku you can use GitHub as your deployment method and enable automatic deployments, but have it configured to wait for the CI to pass first.

   ![Heroku GitHub deployment method](/assets/images/posts/configure-travis-ci-for-ruby-on-rails/1.3.png)

   ![Heroku automatic deployments that wait for CI to pass](/assets/images/posts/configure-travis-ci-for-ruby-on-rails/1.4.png)
