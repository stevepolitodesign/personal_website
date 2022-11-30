---
title: Auto Update Copyright In Drupal Footer
tags: ["Tutorial"]
categories: ["Drupal 7"]
resources: [{title: "Token Filter", url: "https://www.drupal.org/project/token_filter"}, {title: "Token", url: "https://www.drupal.org/project/token"}]
date: 2015-04-08
node: 136
---

Most websites have a copyright in the footer, like ©2015. However, if you do this using static text, you'll need to be sure to update this annually. Wouldn't it be nice to automate this process?

With [Token Filter](https://www.drupal.org/project/token_filter) you can easily achieve this. Below are the steps to make it happen.

1. Download and enable [Token Filter](https://www.drupal.org/project/token_filter) and [Token](https://www.drupal.org/project/token).  
  
![](/assets/images/posts/auto-update-copyright-drupal-footer/Screen-Shot-2015-04-08-at-8.26.58-PM.png)  
 
2. Select a text format or formats that you wish to apply Token Filter to. Select **Replace tokens**. This can be found under **admin/config/content/formats**
  
![](/assets/images/posts/auto-update-copyright-drupal-footer/Screen-Shot-2015-04-08-at-8.27.22-PM.png)  
 
3. Now add a block under **admin/structure/block/add**. Make sure the text format is set to the format or formats you edited in step 2. You can now use [tokens](https://www.drupal.org/node/390482) to dynamically update the year, or add your site's name.  
  
![](/assets/images/posts/auto-update-copyright-drupal-footer/Screen-20Shot-202015-04-08-20at-208.00.18-20PM.png)  
 
4. Now you have an auto updating copyright block!  
  
![](/assets/images/posts/auto-update-copyright-drupal-footer/Screen-Shot-2015-04-08-at-8.27.42-PM.png)

