---
title: "Why I Think Rails is Still Relevant in 2019"
categories: ["Ruby on Rails"]
tags: ["Opinion"]
resources:
  [
    {
      title: "DRY principle",
      url: "https://guides.rubyonrails.org/getting_started.html#what-is-rails-questionmark",
    },
    {
      title: "partial",
      url: "https://guides.rubyonrails.org/getting_started.html#using-partials-to-clean-up-duplication-in-views",
    },
    { title: "testing", url: "https://guides.rubyonrails.org/testing.html" },
    { title: "Rails Guide", url: "https://guides.rubyonrails.org/index.html" },
    {
      title: "Turbolinks",
      url: "https://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbolinks",
    },
  ]
date: 2019-08-27
---

There is currently a high demand for Javascript developers, which in turn dictates the content and curriculum of many tutorials, articles and Boot Camps. Therefore, if you're new to web development or maybe strictly just a front end web developer, you probably don't hear a lot about [Ruby on Rails](https://rubyonrails.org) these days. I'm here to make a case that Rails is still a very relevant tool in 2019, and should not be overlooked when starting a new project.

The point of this article isn't to pit Rails against Javascript, but rather to highlight the features that makes Rails so powerful. After all, [GitHub](https://github.com) (the website nearly all web developers push their code to) is built on Rails.

## Rails Encourages Good Coding Practices

Rails is the reason I even know about the concept of [DRY](https://guides.rubyonrails.org/getting_started.html#what-is-rails-questionmark).

> **Don't Repeat Yourself:** DRY is a principle of software development which states that "Every piece of knowledge must have a single, unambiguous, authoritative representation within a system." By not writing the same information over and over again, our code is more maintainable, more extensible, and less buggy.

An example of the DRY principle can be seen in the use of a [partial](https://guides.rubyonrails.org/getting_started.html#using-partials-to-clean-up-duplication-in-views). The concepts of DRY coding and using partials aren't unique to Rails. However, since Rails encourages these practices, your code base is much easier to maintain and read.

This skill translates well when working in other programing languages or libraries. For example, React makes heavy use of [Components](https://reactjs.org/docs/components-and-props.html#extracting-components), which...

> ...let you split the UI into independent, reusable pieces, and think about each piece in isolation

Along with partials and the DRY principle, Rails makes heavy use of the [command line](https://guides.rubyonrails.org/command_line.html). Knowing how to navigate and interact with the command line is a crucial part of being a programmer, regardless of the programming language. Furthermore, Rails ships with a [debugger](https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-byebug-gem) that runs in the command line. Knowing how to debug your code is imperative, and is something you'll be required to do on any application.

## Rails Encourages Automated Testing, and Ships with a Testing Framework

Automated testing (in any framework, language or library) is often overlooked or ignored. Automated testing ensures your code adheres to the desired functionality even after some major code refactoring. I can't stress how important this is. If you're not writing tests for your application (regardless of the language), then you're not doing your job. The problem with testing is that it can be a pain to set up, or it only tests part of the application. Fortunately Rails [ships with a testing framework](https://guides.rubyonrails.org/testing.html#introduction-to-testing), so there's absolutely no set up.

## Rails Has Excellent Documentation

A lot of time spent as a developer is reading documentation. It doesn't matter how good a library or framework promises to be if it's not well documented. This makes the barrier to entry much more difficult, and will negatively affect your experience with the platform. The most impressive piece of the Rails documentation is the [getting started guide](https://guides.rubyonrails.org/getting_started.html). It's a step by step outline on how to create a blog with associated comments and users backed by a database. It's a very practical guide which demonstrates many of Ruby on Rails' key concepts. Aside from the getting started guide, the [entire guide](https://guides.rubyonrails.org/index.html) is easy to navigate and digest.

## Rails is Mature and Stable

I think one of the main reasons Rails isn't as prominent as it used to be is because it's so mature and stable. Rails was [initially released in 2005](https://en.wikipedia.org/wiki/Ruby_on_Rails), so the implication is that it's old and outdated. However, that could not be further from the truth.

> Ruby on Rails' influence on other web frameworks remains apparent today, with many frameworks in other languages borrowing its ideas, including Django in Python, Catalyst in Perl, Laravel and CakePHP in PHP, Phoenix in Elixir, Play in Scala, and Sails.js in Node.js.

Because Rails has been around for so long, you can be confident that it's battle tested. If massive web applications like GitHub and Airbnb run on Rails, then you can be confident that your application can too.

## Rails Ships With Turbolinks, Which Makes Your App Feel Like a SPA

Because front end libraries like React are so ubiquitous today, developers feel they NEED to use a front end library to make their application feel fast. Fortunately Rails ships with the [Turbolinks library](https://guides.rubyonrails.org/working_with_javascript_in_rails.html#turbolinks).

> Turbolinks attaches a click handler to all `<a>` tags on the page. If your browser supports PushState, Turbolinks will make an Ajax request for the page, parse the response, and replace the entire `<body>` of the page with the `<body>` of the response. It will then use PushState to change the URL to the correct one, preserving refresh semantics and giving you pretty URLs.

Essentially this makes your application act like a SPA (single page app), but with the added benefit of SSR (server side rendering). Below is recording of a Rails application I built. Notice that the browsers doesn't refresh between pages (look at the upper left hand corner of the browser). This is all thanks to Turbolinks, which I never even needed to configure.

![turbolinks demo](/assets/images/posts/why-i-think-rails-is-still-relevant-in-2019/turbolinks-demo.gif)

## Rails Allows You to Build an Entire Full Stack Application Without Depending Upon a External APIs or Services

It took me a long time to truly understand the difference between front end, back end, and full stack. My problem was that I originally thought front end libraries like React also handled data persistance and authentication. However, this is not the case (duh). Since front end libraries are only concerned with rendering content in the browser, they need to be connected to services like [Firebase](https://firebase.google.com/) or [mongoDB](https://www.mongodb.com) to handle data persistance and authentication. This isn't inherently a bad thing, but it does mean that you are dependent upon a third party service for your back end. Rails however, handles the front end and back end for you through abstractions like [Active Record](https://guides.rubyonrails.org/active_record_basics.html). This means that both the front and back ends are in the same codebase.

## Rails Allows a Single Developer or Small Team to Build a Fully Functioning Web Application Quickly and Effectively

I'm speaking on personal experience here. The most recent Rails app I built is [Simple Site Status](https://www.simplesitestatus.com/) which has the following functionality.

- User authentication and authorization
- Custom scheduled jobs to check the status of a website
- Custom e-mail notifications when a site goes offline

I was able to build this application by myself within a few months in my spare time not because I'm a particularly good programmer, but because of how effective Rails is. It gave me the tools to create custom jobs, email notifications, user authentication and more, all while encouraging me to write tests to ensure code quality. I was able to do this all in one code base. If I were to have build this with another stack, I would have needed to rely on several different libraries and services.
