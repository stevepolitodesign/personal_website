---
title: Load Content In Drupal Via AJAX (Without Coding)
tags: ["Tutorial", "AJAX"]
categories: ["Drupal 7"]
resources:
  [
    {
      title: "jQuery AJAX Load",
      url: "http://www.drupal.org/project/jquery_ajax_load",
    },
  ]
date: 2015-07-12
node: 142
---

Loading content via Ajax can create a great user experience. Instead of loading a totally new page, the desired content is loaded on the existing page in a designated location.

In this tutorial I am going to show you how to load node content using the [jQuery AJAX Load Module](https://www.drupal.org/project/jquery_ajax_load). This means we do not need to write any code or custom modules unlike other Drupal AJAX methods.

Below is the final product. It’s a video gallery comprised of thumbnails. When a user clicks a thumbnail, the corresponding video will load at the top of the page.

![](/assets/images/posts/load-content-drupal-ajax-without-coding/afax-2.gif)

Remember, this is just one of many examples that demonstrate what you can do with AJAX.

First you will need to download and enable the [jQuery AJAX Load module](https://www.drupal.org/project/jquery_ajax_load). You will also need to enable the jQuery AJAX Load Node submodule.

![](/assets/images/posts/load-content-drupal-ajax-without-coding/Screen-Shot-2015-07-11-at-10.51.05-AM.png)

Then, navigate to the jQuery AJAX Load configuration page **(admin/config/development/jquery_ajax_load)**.

![](/assets/images/posts/load-content-drupal-ajax-without-coding/Screen-Shot-2015-07-11-at-10.54.48-AM.png)

For this tutorial, you can use the defaults.

The **Valid jQuery Classes/IDs to trigger TB Modal via Ajax (One per line)** field is where you can add classes to the trigger link. The trigger link is the link(s) that will open the corresponding node content on the page via AJAX. I will use the default `.jquery_ajax_load` class.

The **A valid jQuery ID where AJAX callback will be rendered** field is where you define an ID that will be used on an element to display the node content. You can only define one ID, so we will use the default `#jquery_ajax_load_target`.

I kept **Check if you want link to act as toggle buttom** and **Check if you want link to use jQuery show and hide effects** checked be default, but these are not crucial to loading content via AJAX.

Now navigate to a content type configuration page **(admin/structure/types)**, and click **mange display** next to the content type(s) you wish to load via AJAX.

You will notice a new view mode called **jQuery AJAX Load**. This is where you can adjust the display for the node when it’s loaded via AJAX. In my case, I am only showing the video field.

![](/assets/images/posts/load-content-drupal-ajax-without-coding/Screen-Shot-2015-07-11-at-10.52.16-AM.png)

Next you need to create a view. For this tutorial, I created a page view that will display video thumbnails. The thumbnails will link to their node content, which will be displayed using the jQuery AJAX Load display.

To do this you need to add at least two fields. I added the video field, and excluded it from the display. Then I added **Content: path**, and rewrote the results to the following:

![](/assets/images/posts/load-content-drupal-ajax-without-coding/Screen-Shot-2015-07-11-at-10.52.56-AM.png)

![](/assets/images/posts/load-content-drupal-ajax-without-coding/Screen-Shot-2015-07-11-at-10.53.40-AM.png)

![](/assets/images/posts/load-content-drupal-ajax-without-coding/Screen-Shot-2015-07-11-at-10.53.27-AM.png)

```text
<a href="[path]" class="jquery_ajax_load">[field_video]</a>
```

Again, this is specific to my video thumbnail gallery. The important thing to remember is to have the URL link directly to the node, and make sure the link has a class of `jquery_ajax_load`.

Next, I added a **Global: Text area** field to the **HEADER** section of my view. This is were the content will be loaded.

![](/assets/images/posts/load-content-drupal-ajax-without-coding/Screen-Shot-2015-07-11-at-10.54.10-AM.png)

I added `<div id="jquery_ajax_load_target">Click a Video Thumbnail To Begin Watching</div>` into this field. The most important thing to remember is to give an element an ID of `jquery_ajax_load_target`. I added a note saying **Click a Video Thumbnail To Begin Watching** just to help with the user experience. This will disappear when the user clicks a thumbnail and loads a video.

![](/assets/images/posts/load-content-drupal-ajax-without-coding/Screen-Shot-2015-07-11-at-10.54.25-AM.png)

I just want to emphasize that this is one of many ways you can load content via AJAX not only with Drupal, but with the jQuery AJAX Load Module. I didn’t necessarily need to use views. As long as I had the jQuery AJAX Load Node submodule enabled, any link(s) with the class `jquery_ajax_load` that linked to a node would have loaded on a page via AJAX if that page had an element with the ID `jquery_ajax_load_target`.
