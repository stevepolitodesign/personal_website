---
layout: default
title: "Latest Posts From Steve Polito"
meta:
 - content: "Read the latest posts on WordPress, Drupal, Rails and Web Development"
 - keywords: "WordPress, Ruby on Rails, Full Stack"
---

# Blog

{% for post in site.posts %}
  -  <a href="{{ post.url }}">{{ post.title }}</a>
{% endfor %}
