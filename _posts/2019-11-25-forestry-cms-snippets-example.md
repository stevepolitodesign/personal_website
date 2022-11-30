---
title: "Forestry CMS Snippets Demo"
categories: ["Web Development", "JAMstack"]
resources: [
    {
        title: "Source Code",
        url: "https://github.com/stevepolitodesign/forestry-cms-snippets-example"
    },
    {
        title: "Forestry CMS Snippets Documentation",
        url: "https://forestry.io/docs/settings/snippets/"
    }
]
date: 2019-11-25
---

`youtube:https://www.youtube.com/embed/lUd9SQCkDj0`

Snippets in Forestry are pre-defined chunks of text that can be inserted into your content. Think of them like WordPress Shortcodes. In this tutorial I will show you how to create a reusable snippet to embed responsive iframes.

![forestry snippets demo](/assets/images/posts/forestry-cms-snippets-example/demo.gif)

## 0. Prerequisites

This tutorial assumes you have a site up and running on Forestry. I will be using Jekyll in this tutorial, but Forestry works with all major static site generators. Also note that the [responsive embed](https://getbootstrap.com/docs/4.3/utilities/embed/#example) works because of Bootstrap. I created a [Jekyll Boostrap Starter Theme](https://github.com/stevepolitodesign/jekyll-bootstrap-starter-theme) if you'd like to follow along.

## 1. Creating a Custom Snippet

1. Create a `.forestry/snippets` directory.
2. Create a file ending in `.snippet` in the `.forestry/snippets` directory.
    1. In this case, I created a file called `iframe.snippet`

```html
<!-- iframe.snippet -->
<div class="embed-responsive embed-responsive-16by9">
  <iframe class="embed-responsive-item" src="" allowfullscreen></iframe>
</div>
```

Now this code will be available as snippet when using the content editor.