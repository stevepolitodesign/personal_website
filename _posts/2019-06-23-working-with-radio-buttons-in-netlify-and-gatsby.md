---
title: Working with Radio Buttons in Netlify and Gatsby
resources:
  [
    {
      title: "Example Code",
      url: "https://github.com/stevepolitodesign/netlify-gatsby-radio-buttons-example",
    },
    {
      title: "Netlify Form Handling Documentation",
      url: "https://community.netlify.com/t/checkboxes-and-radio-buttons-in-forms/1486/2",
    },
  ]
categories: ["Netlify", "Gatsby"]
date: 2019-06-23
---

I recently ran into an issue with Netlify form submissions on a Gatsby site. Specifically, it had to do with a group of radio buttons. I was using Bootsrap, and just used the [example code](https://getbootstrap.com/docs/4.3/components/forms/#default-stacked) as a starting point to build my form. However, I noticed that my results for that field were not saving correctly.

## Problem

If you don't wrap the `input` in a `label`, the results will save incorrectly as seen below. "Small" should really be "size", since "size" is the name of the `input`

```html
<input type="radio" name="size" id="small" value="small" required />
<label htmlFor="small">Small</label>
```

![Netlfiy form results that are incorrectly saved](/assets/images/posts/working-with-radio-buttons-in-netlify-and-gatsby/incorrect.png)

## Solution

Wrap the `input` in a `label` to ensure the name of the `input` is used in the results.

```html
<label>
  <input type="radio" name="size" id="small" value="small" required /> Small
</label>
```

![Netlfiy form results that are correctly saved](/assets/images/posts/working-with-radio-buttons-in-netlify-and-gatsby/correct.png)
