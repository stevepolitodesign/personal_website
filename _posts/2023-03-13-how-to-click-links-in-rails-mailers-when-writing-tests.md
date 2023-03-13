---
title: "How to click links in Rails Mailers when writing tests"
excerpt: "
  When writing an integration or system test in Rails, have you ever needed to
  click a link in an email? This is especially important for testing links with a
  unique token or that expire, such as password reset emails. Simply checking that
  the link exists is not sufficient, since the page it leads to is ephemeral.
  "
categories: ["Ruby on Rails"]
tags: ["Testing"]
---

In this tutorial, you'll learn how to write a test that clicks a link in a
Rails mailer. This is particularly useful when testing emails with links that
require unique tokens or may expire, such as password reset emails. We'll cover
the steps to create a helper method that uses Capybara to find and click the
link in the email, allowing you to fully test the functionality of a passpword
reset email.

## Find the link using Nokogiri

To extract links from emails, we can use [Nokogiri][1]. Nokogiri converts the
body of the email into a document object, which we can navigate to extract links
based on their text.

```ruby
# test/integration/password_reset_test.rb
require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  test "resets password" do
    user = User.create!(email: "user@example.com")

    post user_password_path, params: { user: { email: "user@example.com"} }

    # ℹ️ Get the latest email
    email = ActionMailer::Base.deliveries.last
    # ℹ️ Parse the email's HTML with Nokogiri
    doc = Nokogiri::HTML(email.body.to_s)
    # ℹ️ Find the link using Nokogiri
    url = doc.at_css('a:contains("Change my password")')[:href]
    # => "http://www.example.com/users/password/edit?reset_password_token=123abc"

    get url

    assert_select "h1", text: "Change your password"
  end
end
```

## Replace Nokogiri with Capybara

One way to improve the current implementation is by swapping out Nokogiri for
[Capybara][2]. This would enhance the readability of the test and allow us to
utilize Capybara's DSL to locate more email content.

```ruby
# test/integration/password_reset_test.rb
require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  test "resets password" do
    user = User.create!(email: "user@example.com")

    post user_password_path, params: { user: { email: "user@example.com"} }

    # ℹ️ Get the latest email
    email = ActionMailer::Base.deliveries.last
    # ℹ️ Parse the email's HTML with Capybara
    page = Capybara.string(email.body.to_s)
    # ℹ️ Find the link using Capybara
    url = page.find(:link, "Change my password")[:href]
    # => "http://www.example.com/users/password/edit?reset_password_token=123abc"

    get url

    assert_select "h1", text: "Change your password"
  end
end
```

## Create a test helper to return the link

The Capybara implementation is helpful, but it could be made simpler. We can
create a method that takes an email and a string, and uses Capybara to find and
return the link with that text. This method could be extracted into a helper to
hide the implementation details.

Since it’s best practice for mailers to use absolute URLs, we can take this
opportunity to convert them to relative URLs. The reason for this is to avoid
making requests to "example.com" which is the default test host for Rails action
mailer. This isn't an issue for integration tests, but it can cause problems for
system tests because Capybara may try to visit the external URL instead of
staying on the localhost.

```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  # ℹ️ Get the link from the email
  def email_link(email, string)
    document = Capybara.string(email.body.to_s)
    link = document.find(:link, string)[:href]

    # ℹ️ Return the relative link to ensure the request stays local
    localize_link(link)
  end

  private

  def localize_link(link)
    uri = URI.parse(link)

    if uri.query
      "#{uri.path}?#{uri.query}"
    else
      uri.path
    end
  end
end
```

```ruby
# test/integration/password_reset_test.rb
require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  test "resets password" do
    user = User.create!(email: "user@example.com")

    post user_password_path, params: { user: { email: "user@example.com"} }

    email = ActionMailer::Base.deliveries.last
    # ℹ️ Our helper hides the implementation and returns the relative url
    get email_link(email, "Change my password")

    assert_select "h1", text: "Change your password"
  end
end
```

## Create a test helper to set the current email

To make our test easier to read, we can create another helper. This helper will
find the most recent email sent to a specific email address and set it as the
`current_email`. Without this helper, the `current_email` will just default to
the last email sent, regardless of the recipient.

```ruby
# test/test_helper.rb
class ActiveSupport::TestCase
  # ℹ️ Find the latest email sent to a particular email address
  def open_latest_email_for(email_address)
    @current_email = ActionMailer::Base.deliveries.reverse.detect do |email|
      email.to.include?(email_address)
    end
  end

  # ℹ️ If the @current_email is not set, default to the last email delivered
  def current_email
    @current_email ||= ActionMailer::Base.deliveries.last
  end

  def email_link(email, string)
    document = Capybara.string(email.body.to_s)
    link = document.find(:link, string)[:href]

    localize_link(link)
  end

  private

  def localize_link(link)
    uri = URI.parse(link)

    if uri.query
      "#{uri.path}?#{uri.query}"
    else
      uri.path
    end
  end
end
```

```ruby
# test/integration/password_reset_test.rb
require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  test "resets password" do
    user = User.create!(email: "user@example.com")

    post user_password_path, params: { user: { email: "user@example.com"} }

    # ℹ️ This will set the @current_email
    open_latest_email_for("user@example.com")
    # ℹ️ Now we can pass current_email to the method
    get email_link(current_email, "Change my password")

    assert_select "h1", text: "Change your password"
  end
end
```

[1]: https://nokogiri.org
[2]: https://teamcapybara.github.io/capybara/
