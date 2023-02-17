---
title: Using Feature Detection to Drop Support for Older Browsers
resources:
  [
    { title: "Modernizr", url: "https://modernizr.com/" },
    { title: "Browse Happy", url: "https://browsehappy.com/" },
  ]
categories: ["Web Development"]
excerpt: A lot of people are familiar with conditional classes, which is a great
  alternative to conditional stylesheets or css hacks. However, these only target
  IE. Even though most of us have become dependent on modern browsers like Chrome
  or Firefox, we still forget that they are not immune to problems. And let’s not
  forget mobile browsers like Opera Mini or Android Browser.
date: 2015-04-03
---

> **EDIT** This is an old article, and the recomendations are no longer best practice.

A lot of people are familiar with [conditional classes](http://www.paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/), which is a great alternative to conditional stylesheets or css hacks. However, these only target IE. Even though most of us have become dependent on modern browsers like Chrome or Firefox, we still forget that they are not immune to problems. And let's not forget mobile browsers like Opera Mini or Android Browser.

This is were feature detection and [Modernizr](http://modernizr.com/) come into play. With Modernizr, you can see if a browser supports a feature, such as css3 transforms. If it doesn't, a class of no-transform will be added to the `<html>`. This allows you to not just target IE, but any browser, and then then create a fallback.

So, what if you're looking to drop support, rather than create a fallback? Using jQuery, I append the affected `<html>` with a code snippet letting users know their browser is not supported. This is better than always having this snippet in the code because it will be the top most element, so search engines and screen readers will pick it up.

```javascript
$("html.no-csstransforms").prepend(
  "<div class='browsehappy'><p>You are using an <strong>outdated</strong> browser. Please <a href='http://browsehappy.com/''>upgrade your browser</a> to improve your experience.</p></div> "
);
```

Then you can use css or scss to style it.

```css
.browsehappy {
  background: red;
  color: white;
  padding: 20px;
  text-align: center;

  a {
    &:link,
    &:visited {
      color: white;
    }
    &:hover,
    &:active {
      color: black;
    }
  }
}
```

Below is the final result. This is what a user will see when visiting my website in IE8. They will see the same message if viewing in a browser that does not support csstransforms.

![](/assets/images/posts/using-feature-detection-drop-support-older-browsers/Screen-Shot-2015-04-07-at-3.55.48-PM.png)
