---
title: In Defense of WordPress
date: 2020-01-26
categories: ["WordPress"]
tags: ["Opinion"]
---

WordPress is said to power [35% of the internet](https://kinsta.com/wordpress-market-share/), yet it seems to get a lot of criticism amongst developers. I’ve been developing with WordPress for roughly 5 years and can empathize with many of the critiques. However, I think that most of the complaints can be attributed to misconceptions and bad first impressions. WordPress is just another technology, and is only as good as the developer it’s used by.

## Don't Associate WordPress with the Site You Inherited

WordPress' biggest strength can also be its biggest weakness. Because WordPress is so ubiquitous and the barrier to entry is so low, almost anyone can get a site up and running. This means that a lot of people building sites in WordPress are not developers. Although WordPress Core is secure, fast, and scalable, it's not immune from an inexperienced site builder. However, the same can be said for any framework, CMS, library or stack. If you were to inherit a project built in any technology from an inexperienced developer, you'd probably start to dislike that technology as well.

## Plugins Aren't All Bad

It's not a bad thing that WordPress makes it so easy to download plugins to extend the functionality of a site. [RubyGems](https://rubygems.org/) and [npm](https://www.npmjs.com/) are the equivalent to the [WordPress Plugin Directory](https://wordpress.org/plugins/). The same criticisms made about bloating a WordPress site with insecure and slow plugins could be made about other ecosystems. For example, in the JavaScript community developers use npm to install packages. These packages can still be [insecure](https://www.npmjs.com/advisories) or even [malicious](https://blog.npmjs.org/post/180565383195/details-about-the-event-stream-incident). The key is to avoid plugins when you can just code the feature yourself. WordPress has [great documentation](https://developer.wordpress.org/), and even a [command line tool](https://developer.wordpress.org/cli/commands/) to help custom development.

## WordPress Theme Development Is More Modern Than You Think

Most people associated WordPress with bloated themes built on visual editors. However, the WordPress ecosystem has excellent options for developing modern themes from scratch such as [Underscores](https://underscores.me/) or [Sage](https://roots.io/sage/). In my opinion, learning to develop a custom theme in WordPress will solve many of the problems associated with WordPress such as plugin bloat and a sloppy interface.

## Hosting Is Important

Choosing the right host is so important, yet often overlooked. It doesn't matter how well you developed your site if it's hosted in a sub optimal environment as performance and security will suffer. This is even more true if you inherited a bloated, clunky site. Do yourself a favor and don't host your WordPress site in a shared environment. Use managed hosting instead.

## WordPress Isn't Always the Right Tool for the Job

Just like all technologies, there's not only a limit to what WordPress can do, but there's also specific situation when to use WordPress. Because WordPress is so easy to get up and running, and because there's a plugin for almost anything, it's easy to think that you can build the next Facebook in WordPress. This is a big pitfall and is another reason WordPress can get a bad reputation. WordPress is a great solution for building a blog, marking site, e-commerce store or even a something more unique. For example, I've utilized [custom post types](https://wordpress.org/support/article/post-types/#custom-post-types) and [custom taxonomies](https://wordpress.org/support/article/taxonomies/) to create several tourism websites with in WordPress. However, this doesn’t mean I would choose WordPress to build a SPA, or a web application.
