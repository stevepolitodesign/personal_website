---
title: Make URL Patterns Match Menu Position in Drupal
tags: ["Quick Tip", "Tutorial", "Pathauto"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Pathauto", url: "https://www.drupal.org/project/pathauto" },
    {
      title: "Pathauto Menu Link",
      url: "https://www.drupal.org/project/pathauto_menu_link",
    },
  ]
date: 2015-11-24
node: 153
---

Drupal's [Pathauto](https://www.drupal.org/project/pathauto) is a must have for any Drupal project. This tutorial will demonstrate a simple yet effective way to utilize Pathauto to create custom URL patterns that match the node's menu position.

Below is an example of the final product. The left side is the menu hierarchy, and the right side is the URL pattern that will be generated.

![](/assets/images/posts/make-url-patterns-match-menu-position-drupal/path-alias-menu-pattern.jpg)

## Enable The Following Modules

In order to create custom URL patterns that match the node's menu position you will need to install and enable the following modules and their dependencies.

1. [Pathauto](https://www.drupal.org/project/pathauto)
2. [Pathauto Menu Link](https://www.drupal.org/project/pathauto_menu_link)

![](/assets/images/posts/make-url-patterns-match-menu-position-drupal/Screen-Shot-2015-11-23-at-8.20.46-PM.png)

The reason we also install ​Pathauto Menu Link can be explained in the module's description.

> If you use parent menu links to generate paths within Pathauto, you'll notice that the resulting path is only updated when a node is saved, which means that if you simply move a menu link item within a menu so that it has a different parent, the path is immediately out of date and no longer correct.
>
> This module fixes that by forcing an update of the Pathauto-generated path when a menu link item has been updated, based of the link's new position within the menu tree.

## Create A Path Alias

Now that you've installed and enabled Pathauto and Pathauto Menu Link, you can create a path alias that will match the node's menu position.

1. Navigate to **admin/config/search/path/patterns** and create a new path alias using `[node:menu-link:parents:join-path]/[node:title]`. ![](/assets/images/posts/make-url-patterns-match-menu-position-drupal/Screen-Shot-2015-11-23-at-8.52.47-PM.png)

## Add Nodes To a Menu

Now when you add a node to a menu, it will automatically add the node's menu parent to the path alias. If the node doesn't have a parent, the alias will simply default to the node title.
