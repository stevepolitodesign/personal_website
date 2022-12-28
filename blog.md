---
layout: default
title: "Blog"
meta:
 - content: "Read the latest posts on WordPress, Drupal, Rails and Web Development"
 - keywords: "WordPress, Ruby on Rails, Full Stack"
---

{% for post in site.posts %}
  -  <a href="{{ post.url }}">{{ post.title }}</a>
{% endfor %}
