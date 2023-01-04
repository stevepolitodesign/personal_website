---
title: Move a Block to a Different Region on Mobile Layouts in Drupal
categories: ["Drupal 7"]
resources:
  [
    { title: "Breakpoints", url: "https://www.drupal.org/project/breakpoints" },
    {
      title: "Context Breakpoint",
      url: "https://www.drupal.org/project/context_breakpoint",
    },
    {
      title: "Mobile Switch",
      url: "https://www.drupal.org/project/mobile_switch",
    },
    {
      title: "Context Mobile Switch",
      url: "https://www.drupal.org/project/context_mobile_switch",
    },
    { title: "Bootstrap", url: "https://www.drupal.org/project/bootstrap" },
  ]
date: 2015-09-19
node: 146
---

Thanks to [CSS3 Media Queries](http://www.w3schools.com/cssref/css3_pr_mediaquery.asp) web developers can create a completely different layout for their websites when viewed on small screens. Drupal offers a lot of mobile first, responsive themes such as [Omega](https://www.drupal.org/project/omega), [Adaptive Theme](https://www.drupal.org/project/adaptivetheme) and [Zen](https://www.drupal.org/project/zen) that do just this. However, there are circumstances when using responsive design is just not enough. When a user is viewing a website on a small screen, their experience is drastically different than that of a desktop user. Because of this, it might be necessary to move, replace, or even completely hide elements on the page.

In this tutorial I will show how to change a block's positions for a mobile layout. Since this applies to responsive website, I'm going to be using the [Bootstrap](https://www.drupal.org/project/bootstrap) theme.

![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.51.46-PM.png)

> The login block will appear in the sidebar for desktop users.

![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.51.33-PM.png)

> The login block will appear in the navigation for mobile users.

## Configure Breakpoint

1. First we will need to install [Breakpoint](https://www.drupal.org/project/breakpoints).
2. Once installed, navigate to the settings page at **admin/config/media/breakpoints.** The following configuration is just an example. You can use breakpoints that best fit your theme.
   1. Add a breakpiont for mobile screens called **Mobile** and set it to **(max-width: 480px)**
   2. Add a breakpiont for desktop screens called **Desktop** and set it to **(min-width: 481px)​** ![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.33.48-PM.png)

## Configure Your Site's Performance

[Context Breakpoint](https://www.drupal.org/project/context_breakpoint) has caching limitations as documented [here](http://cgit.drupalcode.org/context_breakpoint/tree/README.txt?id=refs/heads;id2=7.x-1.x). However, there are a few work arounds. Performance is a very important issue when it comes to web development, so make sure you enable **Cache pages for anonymous users** and **Cache blocks.**

![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.36.56-PM.png)

## Configure Context Breakpoint

Because we enabled page caching on our site, any block in a context breakpoint context will not appear. However, there is a solution.

1. Now install and enable [Context Breakpoint](https://www.drupal.org/project/context_breakpoint).
2. Navigate to **admin/config/media/context-breakpoint** and configure the following.
   1. Check **Disable reload on admin pages**
   2. Check **Save resolution in cookie** ![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.34.13-PM.png)

## Configure Blocks

Navigate to **admin/structure/block** and disable the block(s) you wish to cahnge regions. For this tutorial, I disabled the **User login** block.

![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.34.33-PM.png)

## Create Context

Now we're going to create the context that will change the block's position on a mobile device.

1. Navigate to **admin/structure/context/add** and create a mobile context.
   1. Call the context **mobile_blocks** ![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.35.52-PM.png)
   2. Add a **Breakpoint** Condition and set it to the mobile breakpoint we created earlier.![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-8.47.55-PM.png)
   3. Add a **Blocks** reaction and add place your block into your region of choice. ![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.36.11-PM.png)
2. Navigate to **admin/structure/context/add** and create a desktop context.
   1. Call the context **desktop_blocks** ![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.34.56-PM.png)
   2. Add a **Breakpoint** Condition and set it to the desktop breakpoint we created earlier. ![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-19-at-7.31.53-AM.png)
   3. Add a **Blocks** reaction and add place your block into your region of choice. ![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.35.15-PM.png)
3. If you simply wish to display a block on desktop and not mobile or visa versa, just don't create a context for that breakpoint. You can also use this method to display new blocks at different breakpoints as well.

## Optional: Avoid Caching Issues

The above steps will allow you to change a block's position based the user's browser size. However, there are caching limitations as we discussed. If a user were to resize their browser to the mobile breakpoint size, the block would not change regions. This is because their initial browser size is being stored in a cookie. This isn't necessarily a huge problem however, since it's unlikely a user would need a mobile experience on their desktop. However, if you have a breakpoint that occurs at a larger size, it might be important to force the new layout.

> Just a word of warning, the following steps are experimental. They will alter your site's URL structure, and should be used with caution. I also noticed that once I enabled, EXPERIMENTAL: Add active contexts to url for CACHING, and later disabled it, site breakpoints stopped all together. I needed to disable and re-enable Breakpoints and Context Breakpoint to be able to go back to my original configuration.

1. Navigate back to the context breakpoints configuration page **admin/config/media/context-breakpoint**
   1. ​Enable **EXPERIMENTAL: Add active contexts to url for CACHING**
      ![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-18-at-7.42.35-PM.png)
2. ​Navigate back to the context breakpoints we created earlier.
   1. Enable **Auto-reload** under the **Breakpoint** settings for each context.  
      ![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/Screen-Shot-2015-09-19-at-7.54.37-AM.png)

After that, the layout will change automatically with caching enabled. However, the URL structure has been altered.

![](/assets/images/posts/move-block-different-region-mobile-layouts-drupal/mobile-block-1.gif)
