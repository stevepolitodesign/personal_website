---
title: Bulk Update Redirects After Changing URL Pattern in Drupal
tags: ["SEO", "Tutorial"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Redirect", url: "https://www.drupal.org/project/redirect" },
    {
      title: "Views Bulk Operations",
      url: "https://www.drupal.org/project/views_bulk_operations",
    },
    { title: "Pathauto", url: "https://www.drupal.org/project/pathauto" },
  ]
date: 2015-08-15
node: 144
---

I recently worked on a project where the site's URL structure was going to change. This is easy to do with [Pathauto](https://www.drupal.org/project/pathauto), but I wanted to ensure that the old URLs would redirect to the new URLs since this would affect hundred of nodes.

If you have [Redirect](https://www.drupal.org/project/redirect) enabled and you manually update a node's URL, the module will automatically create a redirect from the old URL to the new URL. However, since I would be updating hundred of nodes I needed an automated process. Below are the steps I took to bulk update redirects after changing a URL pattern.

1. First, update your URL pattern by going to **admin/config/search/path/patterns**. In my case, I updated the patten for Articles. I changed it from **news/[node:title]** to **blog/[node:title]**.

![](/assets/images/posts/bulk-update-redirects-after-changing-url-pattern-drupal/Screen-Shot-2015-08-15-at-8.21.58-AM.png)

![](/assets/images/posts/bulk-update-redirects-after-changing-url-pattern-drupal/Screen-Shot-2015-08-15-at-8.23.46-AM.png)

![](/assets/images/posts/bulk-update-redirects-after-changing-url-pattern-drupal/Screen-Shot-2015-08-15-at-8.24.53-AM.png)

2. After updating the URL pattern, you do NOT need to delete all aliases, or run a bulk update under the **Search and metadata** configuration page. This will not create the redirects.
3. Instead we want to create a new view to run a bulk operation. Create a view with a table display by going to **admin/structure/views/add**. Make sure to limit it to the content types(s) affected.

![](/assets/images/posts/bulk-update-redirects-after-changing-url-pattern-drupal/Screen-Shot-2015-08-15-at-8.27.37-AM.png)

4. Add a field of **Bulk operations: Content**

![](/assets/images/posts/bulk-update-redirects-after-changing-url-pattern-drupal/Screen-Shot-2015-08-15-at-8.28.25-AM.png)

5. Under **Selected Bulk Operations** select **Update node alias**.

![](/assets/images/posts/bulk-update-redirects-after-changing-url-pattern-drupal/Screen-Shot-2015-08-15-at-9.23.04-PM.png)

6. Save the view and go the the page you just created to run the operation.

![](/assets/images/posts/bulk-update-redirects-after-changing-url-pattern-drupal/Screen-Shot-2015-08-15-at-8.31.23-AM.png)

7. After running the bulk operation, navigate to an affected node and scroll to the bottom of the edit screen. You will see a redirect has been added. You can also test this by navigating to the original path and making sure it redirects to the new path instead of creating a 404 error.

![](/assets/images/posts/bulk-update-redirects-after-changing-url-pattern-drupal/Screen-Shot-2015-08-15-at-8.34.43-AM.png)
