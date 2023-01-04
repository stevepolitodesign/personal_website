---
title: Drupal Smartqueue Taxonomy Tutorial
tags: ["Tutorial", "Views", "Taxonomy", "Smartqueue"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Nodequeue", url: "https://www.drupal.org/project/nodequeue" },
    {
      title: "Node Auto Queue",
      url: "https://www.drupal.org/project/auto_nodequeue",
    },
    { title: "Views", url: "https://www.drupal.org/project/views" },
    {
      title: "Views Bulk Operations (VBO)",
      url: "https://www.drupal.org/project/views_bulk_operations",
    },
  ]
date: 2015-07-07
node: 141
---

Drupal allows you to organize content into taxonomies. This is best illustrated in tagging content, similar to Twitter. Drupal then dynamically creates pages that list content that have been categorized with specific taxonomy terms. By default, Drupal organizes content on these taxonomy pages based on post date. The most recently posted content will appear first.

However, what if you want to create a custom sort order? Not based on post date, title or whether or not if the node is sticky, but purely custom. Enter Smartqueue Taxonomy.

Smartqueue Taxonomy is a submodule that...

> Creates a node queue for each taxonomy vocabulary

What this means is that when you associate a node with a term, a nodequeue will be automatically created with that same term name. You can then add this node to that subqueue which will allow you to create custom sort orders for each term.

## Configuring Smartqueue Taxonomy

Before you do anything, you will need to make sure you have a content type that has a term reference field. By default, the **Article ** content type has a term reference field called "tags". For this tutorial, we will use this as our reference.

Next, you will need to download and install [Nodequeue](https://www.drupal.org/project/nodequeue) and [Node Auto Queue](https://www.drupal.org/project/auto_nodequeue). You will then need to then enable Nodequeue, Smartqueue taxonomy and Node Auto Queue.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartque-1.png)

Once these modules are enabled, you will need to create a Taxonomy queue. Navigate to the **admin/structure/nodequeue/add/smartqueue_taxonomy** to do so.

I named my queue after the vocabulary I am using for consistency sake, but you can name it anything you wish. Make sure to select a **Taxonomy fields** field. Again, I am using the default **Article** content type for this tutorial, so there is a **field_tags** option.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartque-2.png)

Next, select the content type you wish to associate this Queue with. I chose **Article** for the reason above.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartque-3.png)

Finally, select **Auto add nodes**. This will automatically add the node to the appropriate queue(s) upon saving.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/Screen-Shot-2015-07-06-at-9.05.26-PM.png)

Below is what happens when you add new content. Note how I tag this node as **AddMe**. Once saved, it automatically created a new nodequeue called **AddMe**, and added this node to that queue.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-1.gif)

To see all of your nodequeues, navigate to **admin/structure/nodequeue**

## Automatically Add Existing Content To Smartqueues

The above steps will ensure that any newly created content will be added to a dynamically created smartqueue. However, if you have existing content on your website, you will want to add these nodes to their appropriate smartqueues. By default, the Smartqueue you just created will have no subqueues.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/Screen-Shot-2015-07-06-at-9.32.19-PM.png)

If you have hundreds or thousands of nodes, this would be a tedious task. However, we can easily do this using [Views Bulk Operations (VBO)](https://www.drupal.org/project/views_bulk_operations).

Once installed and enabled, create a new view by going to **admin/structure/views/add**

Create a page that shows **Content** of **type**, and select the appropriate content type. In my case, I am using **Article**. Set the **Display format** to **Table**.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/Screen-Shot-2015-07-06-at-9.17.40-PM.png)

Next, add a new field called **Bulk operations: Content**.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/Screen-Shot-2015-07-06-at-9.20.16-PM.png)

Then, under **Selected Bulk Operations** chose **Add to Nodequeues** and click **Apply**.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/Screen-Shot-2015-07-06-at-9.21.27-PM.png)

Finally, navigate to the page you just created and execute the bulk operation you just created. Be sure to select all nodes, and to select the appropriate nodequeue.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-2.gif)

Now all the subqueues have been created and populated.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/Screen-Shot-2015-07-06-at-9.38.09-PM.png)

## Make Term Pages Respect Custom Sort Order of Smartqueues

Now that we've added all existing and newly created content to the smartqueues, we can update the individual term pages.

As I stated early, the default sort order of each term page is based on post date. This is demonstrated below.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-3.gif)

The first thing we need to do is enable the **Taxonomy term** view. Navigate to **admin/structure/views**, and enable the view.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-4.gif)

Next, ​remove the default contextual filters.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-5.gif)

Then, add a relationship. Select **Nodequeue: Queue**. Require the relationship. You can also select to limit the queues.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-6.gif)

Then, add a contextual filter of **Nodequeue: Subqueue reference**. Make **Provide default value** and for **Type** select **Taxonomy term ID from URL**. Select **Load default filter from term page** and click apply.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-7.gif)

Finally, remove the default configurations for the sort criteria, and add **Nodequeue: Position**. Save the view.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-9.gif)

Now, if I navigate to the subqueue for the particular term we looked at earlier, I can adjust the sort order.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-10.gif)

Below is the same term page as before, but it now respects the sort order of the subqueue.

![](/assets/images/posts/drupal-smartqueue-taxonomy-tutorial/smartqueue-11.gif)
