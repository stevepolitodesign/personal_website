---
title: Track Link Clicks In Drupal
tags: ["Tutorial", "Analytics"]
categories: ["Drupal 7"]
resources:
  [
    {
      title: "Link Click Count",
      url: "https://www.drupal.org/project/link_click_count",
    },
  ]
date: 2015-10-02
node: 147
---

You might be wondering why you would need to track the number of times a link is clicked in Drupal, when this can be done using [Google Analytics](https://support.google.com/analytics/answer/1136920?hl=en) and the [Google Analytics Module](https://www.drupal.org/project/google_analytics). However, by default this just groups all outbound link clicks as "Outbound links". Also (as far as I can tell), this doesn't tell you on what specific page the user clicked that particular link on.

![](/assets/images/posts/track-link-clicks-drupal/Screen-Shot-2015-10-02-at-2.18.35-PM.png)

So, if you have an outbound link on multiple pages, you can't see what page the user was on when they clicked it. Luckily Drupal's [Link Click Count](https://www.drupal.org/project/link_click_count) is a simple solution for tracking both internal and external link clicks. It also ensures that each link (internal or external) will be tracked individually. This means that if you have two nodes that reference the same link, you can see the link click counts for each link individually. This is perfect for A/B testing.

In this tutorial I'll show you how to set up link tracking, and how to view the results.

![](/assets/images/posts/track-link-clicks-drupal/Screen-Shot-2015-10-02-at-7.40.12-PM.png)

## Install Link Click Count

First we'll need to install and enable [Link Click Count](https://www.drupal.org/project/link_click_count) and its dependencies.

![](/assets/images/posts/track-link-clicks-drupal/Screen-Shot-2015-10-02-at-7.02.55-PM.png)

## Configure Link Click Count

Now that the module and its dependencies are installed, let's configure the configure out set up. For this tutorial I'm going to use the default Article content type as an example.

1. Add a new link field at **admin/structure/types/manage/article/fields**. In this case I'm creating a field for any resources an author might add to a post, similar to how my blog is set up. ![](/assets/images/posts/track-link-clicks-drupal/Screen-Shot-2015-10-02-at-7.06.29-PM.png)
2. At the bottom of the settings page for the new field (in my case at **admin/structure/types/manage/article/fields/field_resources** ) configure the following settings.
   1. Select **Save the clicks happened on this link.** ![](/assets/images/posts/track-link-clicks-drupal/Screen-Shot-2015-10-02-at-7.07.41-PM_0.png)
   2. (Optional) set **Number of values** to **UNLIMITED.** ![](/assets/images/posts/track-link-clicks-drupal/Screen-Shot-2015-10-02-at-7.07.56-PM_0.png)
3. ​Save.
4. Now go to this display settings for your content type (in my case at **admin/structure/types/manage/article/display** ) and set your link field's format to **Counts the click happened on this link.** ![](/assets/images/posts/track-link-clicks-drupal/Screen-Shot-2015-10-02-at-7.21.09-PM_0.png)
5. Save.

## Add Some Test Content

Now that we've configured Link Click Count let's test it by adding some content. Add some external and internal links and click on them.

## View Link Click Counts

Now we need to be able to track the links that we've created. By default Link Click Count creates a view that displays this data, and also allows for date filtering. This is especially helpful if you want to gather metrics during a campaign. The default view only has one flaw in my opinion, and that is the fact that anyone who can see published content can see this page. To fix that do the following.

1. Navigate to view at **admin/structure/views/view/link_click_count_stats/edit/page**
2. Under **PAGE SETTINGS** \> **Access:** configure the following.
   1. Set Access restrictions to **Role** ![](/assets/images/posts/track-link-clicks-drupal/Screen-Shot-2015-10-02-at-7.35.49-PM.png)
   2. Select the Role to **administrator** (or any custom admin role you've created)![](/assets/images/posts/track-link-clicks-drupal/Screen-Shot-2015-10-02-at-7.35.57-PM.png)
3. Save.

To view the link click counts just go to the view page at **/link-click-count-stats**.

## Conclusion and Use Cases

[Google Analytics](https://support.google.com/analytics/answer/1136920?hl=en) and the [Google Analytics Module](https://www.drupal.org/project/google_analytics) track outbound links, but they don't provide you with enough detail to out of the box. With the [Link Click Count](https://www.drupal.org/project/link_click_count) module you can easily track the number of clicks on internal or external links associated with a link field. This is perfect for A/B testing, monitoring the success of advertisements or gathering data on user engagement.
