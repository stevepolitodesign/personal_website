---
title: Linking to Content In Drupal
tags: ["Tutorial"]
categories: ["Drupal 7"]
resources: [{title: "CKEditor Link", url: "https://www.drupal.org/project/ckeditor_link"}, {title: "Linkit", url: "https://www.drupal.org/project/linkit"}, {title: "Wysiwyg", url: "https://www.drupal.org/project/wysiwyg"}, {title: "CKEditor", url: "http://ckeditor.com/download"}]
date: 2015-05-28
node: 139
---

If you're using the [Pathauto Module](https://www.drupal.org/project/pathauto), you know that you can create custom path patterns for nodes, taxonomies and users. This is great for SEO, as well as keeping content organized. However, one of the side effects of using Pathauto is that the paths to your content can change.

For example, I use the following pattern for my Article content type:

```
blog/node:title
```

This means that if I change the title of an Article, the URL changes as well. If I am linking to this content elsewhere on my site, that link will now be broken.

Luckily, there are two Drupal modules that make linking to content easy, and consistent.

## CKEditor Link Tutorial

If you're using a WYSIWYG editor, then [CKEditor Link](https://www.drupal.org/project/ckeditor_link) is a must have. It links to the internal Drupal path (ex. /node/1) of each piece of content, rather than the the Pathauto path. It also has a nifty auto complete feature that makes finding the content easy.

First, you will need to have a WYSIWYG editor installed. I prefer using [WYSIWYG](https://www.drupal.org/project/wysiwyg) with [CKEditor](http://ckeditor.com/). Then, install [CKEditor Link](https://www.drupal.org/project/ckeditor_link).

Navigate to the WYSIWYG profiles page ***(admin/config/content/wysiwyg)**, then pick a text format to edit.

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.18.57-PM.png)

Once on a text format edit page, make sure to select **Link** and **CKEditor Link** under **Buttons and Plugins**. Click save.

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.22.27-PM.png)

Finally, make sure to enable **CKEditor Link Filter** on the text format configuration page. For example, if you are applying this to the Filtered HTML text format, you would navigate to this page **(admin/config/content/formats/filtered\_html)**.

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.25.38-PM.png)

Now, when you are trying to link to a piece of content via the WYSIWYG Editor, you can chose  **Internal path** under **Link Type**. If you begin to type the title of a piece of content, it will auto complete.

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.27.56-PM.png)

## Linkit Tutorial

CKEditor Link is great for a field that uses WYSIWYG, but what if you need to link to Drupal content via a Link field? This is where [Linkit Module](https://www.drupal.org/project/linkit) comes in handy. 

Once installed, you will need to add a Linkit Profile **(admin/config/content/linkit/add)**. Since we are working with fields, choose **Fields** under the **Profile Type** tab.

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.38.01-PM.png)

Under the **Search plugins** tab choose the entities you wish Linkit to be able to reference. For this tutorial I will limit my results to nodes. 

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.40.02-PM.png)

Next, under the **Insert methods** tab, choose **Raw URL** for **Insert plugin** and **Raw paths** for **Insert paths as:**.

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.41.57-PM.png)

For this tutorial we will not need to configure anything under the **Attributes** or **Autocomplete options** tabs.

Now navigate to a link field type, and click edit.

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.48.43-PM.png)

Then, scroll until you see **LINKIT FIELD SETTINGS**. Click **Enable Linkit for this field.** and select the profile you just created.

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.51.05-PM.png)

You will now see a **Search** button on this link field. This will allow you to search content via an auto complete widget, and link to it.

![](/assets/images/posts/linking-content-drupal/Screen-Shot-2015-05-28-at-7.53.04-PM.png)