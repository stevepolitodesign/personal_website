---
title: Easily find elements with XPath in Capybara by using Chrome's Dev Tools
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Capybara Documentation",
      url: "https://github.com/teamcapybara/capybara#xpath-css-and-selectors",
    },
  ]
date: 2020-07-31
---

Imagine you have multiple identical elements on a page and that you need to select a specific element during a [system test](https://guides.rubyonrails.org/testing.html#system-testing).

![identical elements](/assets/images/posts/easily-find-elements-with-xpath-in-capybara-by-using-chromes-dev-tools/1.0.png)

If your test were written like this, it would fail with a `Capybara::Ambiguous: Ambiguous match` error.

```ruby
test "opening modal" do
  visit root_path
  click_button("Launch Modal")
end
```

One solution is to use [XPath](https://github.com/teamcapybara/capybara#xpath-css-and-selectors) to target the desired element. However, figuring out the XPath can be tricky. Luckily Chrome's [DevTools](https://developers.google.com/web/tools/chrome-devtools/) give us the ability to easily copy an element's XPath.

![copy an element's XPath using Chrome's Dev Tools](/assets/images/posts/easily-find-elements-with-xpath-in-capybara-by-using-chromes-dev-tools/Copy_Full_XPath.gif)

Now you can use [find with xpath](https://github.com/teamcapybara/capybara#xpath-css-and-selectors) to target the specific element.

```ruby
test "opening modal" do
  visit root_path
  find(:xpath, "/html/body/div/div[1]/button[3]").click
end
```

But what if the development DOM is not the same as your test DOM? One solution is to drop a `byebug` into the system test if you're not using a headless browser. This will keep the browser open and allow you to use the dev tools within the context of the testing browser.

```ruby
test "opening modal" do
  visit root_path
  byebug
end
```

![selenium browser](/assets/images/posts/easily-find-elements-with-xpath-in-capybara-by-using-chromes-dev-tools/2.0.png)
