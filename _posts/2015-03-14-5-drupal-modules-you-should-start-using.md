---
title: 5 Drupal Modules You Should Start Using
tags: ["Modules"]
categories: ["Drupal 7"]
resources:
  [
    {
      title: "Node Auto Queue",
      url: "https://www.drupal.org/project/auto_nodequeue",
    },
    { title: "Linkit", url: "https://www.drupal.org/project/linkit" },
    {
      title: "Field as Block",
      url: "https://www.drupal.org/project/fieldblock",
    },
    {
      title: "Image Link Formatter",
      url: "https://www.drupal.org/project/image_link_formatter",
    },
    {
      title: "Field Formatter Class",
      url: "https://www.drupal.org/project/field_formatter_class",
    },
  ]
date: 2015-03-14
node: 133
---

Every Drupal developer knows about the heavy hitters like views, display suite and context. However, this is a list of 5 Drupal Modules that I use frequently, because they save time and make client administration easier.

## Node Auto Queue

> This module provides an additional setting on the Nodequeue edit screen called **"Auto add nodes"**. When this option is chosen, any node of a content type associated with this nodequeue will be automatically added to the queue upon creation.

This module does exactly that. Instead of having to save your node, then manually add it to your nodequeue(s), you can now easily do this in one step on the node edit screen. I find that this is most helpful for clients who often forget to add nodes to a nodequeue. This can be problematic if you have a view that is dependent on nodequeues. If you don't add the node to the nodequeue, it will not appear and the client will think the site is broken.

## Linkit

> _Linkit_ provides an **easy interface for internal and external linking** with editors and fields by using an **autocomplete field**.

Until I knew this module existed, I would have to manually link internal pages. This caused a lot of issues for both me, and my clients. For starters, if I updated the title of a node I was linking to, the link would then break because the path changed. Also, clients didn't understand the concept of relative linking (and shouldn't have to.) So, they would use an absolute link to reference a in internal page. This would cause huge problems if the domain were to change, or if the site migrated. Luckily, Linkit takes care of these issues. All you need to do is just search for content on your site and save.

## Field as Block

> _Field as Block_ provides an easy way to display one or more fields of the current node in a block.

Typically, if I want to display a field or fields from a node in a different region other than the main content region, I do the following:

1. Turn their display format to hidden
2. Create a block view that displays the hidden fields with a contextual filter set to NID
3. Add that block to the desired region

This isn't necessarily bad, but it's a lot of steps, and can be a bit overkill. Field as Block allows you to display any field as a block on the Manage Display tab. This creates a block for that field, which you can then place into any region.

## Image Link Formatter

> This module is the result of the discussions around a requested feature to allow an image field to be displayed with a link to a custom URL:

This module easily allows you to display an image as a link under the Manage Display tab. The only requirement is that the content type has a link field. This is a huge time saver. Before I knew this module existed, I would hide the image and link from the display, and create a view where I would wrap the image in the link, and give it a contextual filter.

## Field Formatter Class

> Allows site administrators to add classes to the outer HTML wrapper for any field display, so that CSS and Javascript can target them.

Again, before I knew about this module, I would rely heavily on views where I knew I could control the class of the field. This module saves you the time of having to do that. Because it's so easy to add a class to a field, you can keep your CSS file DRY (don't repeat yourself), instead of having to apply the same styles to the default field classes.
