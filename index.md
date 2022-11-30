---
layout: default
title: "Happy Jekylling!"
---
## Posts

{% for post in site.posts %}
  -  <a href="{{ post.url }}">{{ post.title }}</a>
{% endfor %}

## Categories

{% for category in site.categories %}
  - <a href="{{ 'categories' | relative_url }}/{{ category[0] | slugify }}">{{ category[0] }}</a>
{% endfor %}

## Tags

{% for tag in site.tags %}
  - <a href="{{ 'tags' | relative_url }}/{{ tag[0] | slugify }}">{{ tag[0] }}</a>
{% endfor %}
