---
title: "Unpopular Opinion: WordPress Should Be the First Choice When Building a Website That Won't Be Maintained by a Developer or Agency"
categories: ["WordPress"]
tags: ["Opinion"]
resources:
  [
    {
      title: "Bulls**t Reasons Not to Use a Static Generator",
      url: https://www.netlify.com/blog/2016/05/24/5-bullst-reasons-not-to-use-a-static-generator/,
    },
    {
      title: "CSS-Tricks is a Poster Child WordPress Site",
      url: https://mediatemple.net/blog/news/css-tricks-is-a-poster-child-wordpress-site/,
    },
  ]
date: 2019-05-20
---

I know this article seems like clickbait, so let me try and explain myself before I lose you. In order to understand my viewpoint, it helps to know that I don't think WordPress is the right tool for the job all the time. Rather, I think it's the right tool for the job under specific circumstances. It just so happens that for the type of work I do, these specific circumstances are very common. I work for an agency which builds small to medium sized websites that will eventually be handed off to the client.

To be clear, let me outline the specific criteria a project needs to meet in order for me to chose WordPress.

## My Opinionated Criteria for Choosing WordPress

1. The website will be handed off to the client. The client may not be familiar or comfortable with programming or editing websites.
2. The client needs the ability to edit almost anything that displays publicly. This means that not only should the client be able to add, edit and delete content on the site, but they should also be able to edit items such as the footer, logo and navigation.
3. The client has expressed interest in additional functionality later down the line.

I'm sure at this point some of you are thinking that [Netlify CMS](https://www.netlifycms.org/), or other headless CMS solutions like [Sanity](https://www.sanity.io/) and [Contentful](https://www.contentful.com/) address these issues. I don't disagree that these solutions are appropriate for handling some of the criteria above, but in my opinion they cannot handle **ALL** the criteria above.

To alleviate some bias, it's also important to note [that this very site](https://stevepolito.design/) is built in [Gatsby](https://www.gatsbyjs.org/) and hosted on [Netlify](https://www.netlify.com/). I've also linked to [Bulls\*\*t Reasons Not to Use a Static Generator](https://www.netlify.com/blog/2016/05/24/5-bullst-reasons-not-to-use-a-static-generator/) and [CSS-Tricks is a Poster Child WordPress Site](https://mediatemple.net/blog/news/css-tricks-is-a-poster-child-wordpress-site/) for additional perspective on each side of the argument.

## Reasons Why Choosing the JAMSTACK is Not the Best Option

I'm going to refer to the three items listed under **My Opinionated Criteria for Choosing WordPress** to explain why going JAMSTACK is not always the best option if the website won't be maintained by a developer or agency.

### 1. The website will be handed off to the client. The client may not be familiar or comfortable with programming or editing websites.

I know that this is not enough to justify choosing WordPress. I know that the interface for [Netlify CMS](https://www.netlifycms.org/), [Contentful](https://www.contentful.com/) and [Sanity](https://www.sanity.io/) are user friendly, and are no different from the WordPress editor. However, one key difference (at least now) is that WordPress has [Gutenberg](https://wordpress.org/gutenberg/) which is a drag and drop editor. I know this has caused a lot of division in the WordPress community, but from my experience it's a **very** valuable tool.

Case in point: On nearly every project I've worked on, the client will eventually ~~want~~ **need** to be able to add more than just paragraphs or images to a page. Sometimes they need to add columns, video, quotes or more dynamic content through shortcodes or widgets. The ability to easily adjust a page's layout **and** content comes out of the box in WordPress, but would be more difficult to achieve using the the JAMSTACK.

Since the client is not a developer, they don't have a good grasp on what's an easy change and what's a more time consuming change. From their point of view, they should easily be able to adjust a page layout without having to contact the agency of record.

Finally, the client should be able to easily **preview** and **revert** changes. This doesn't seem to be as straight forward if you're using the JAMSTACK (please correct me if I'm wrong). However, this functionality comes out of the box in WordPress, and is incredibly helpful for a client.

### 2. The client needs the ability to edit almost anything that displays publicly. This means that not only should the client be able to add, edit and delete content on the site, but they should also be able to edit items such as the footer, logo and navigation.

Again, I know that [Netlify CMS](https://www.netlifycms.org/), [Contentful](https://www.contentful.com/) and [Sanity](https://www.sanity.io/) can handle most of this. However, as far as I can tell, they are not as well equipped to handle more specific changes, such as changing the navigation or adding widget like content to specific pages.

> WordPress Widgets add content and features to your Sidebars. Examples are the default widgets that come with WordPress; for Categories, Tag cloud, Search, etc. Plugins will often add their own widgets.

In my opinion this is a **huge** advantage for WordPress. Imagine if you just launched a site and the client wanted to rearrange the order of the elements in the sidebar, or add a new feature to the sidebar all together. If the site is built in WordPress, this is a trivial change that the client could make themselves.

The same goes for the site navigation. WordPress comes with a drag and drop interface that allows users to edit and add navigation menus to the site. As far as I can tell, [Netlify CMS](https://www.netlifycms.org/), [Contentful](https://www.contentful.com/) and [Sanity](https://www.sanity.io/) do not come with this functionality out of the box.

### 3. The client has expressed interest in additional functionality later down the line.

To me, this is the most important reason why I end up choosing WordPress. Some will argue that a client request this vague is outlandish. However, you need to keep in mind that **the client is not a developer**. They don't know how difficult it is to add new features to a website. After all, platforms like Squarespace and Wix are so ubiquitous that it's hard to justify why you **couldn't** easily extend the site's functionality. You don't want to sell them something that is limiting, especially if they've expressed interest in adding new features.

Since the WordPress ecosystem is so large, you're almost guaranteed to find a solution to your problem in the form of a plugin. For example, you can get your site up in running as an fully functioning e-commerce store in a weekend with [WooCommerce](https://woocommerce.com/). Does your client need to add an event calender to the site? No problem. There are [several plugins](https://wordpress.org/plugins/search/calendar/) for that.

Choosing a platform with such a large ecosystem makes any and all feature requests much more manageable.

## Conclusion and Final Thoughts

I realize this article probably comes off as "WordPress > Everything", so let me wrap up with a few concise thoughts.

Before choosing a platform, think from the _client's_ point of view. They're about to spend thousands of dollars on a website, and are looking to you as the expert to guide them. Don't sell them something that is going to be limiting from _their_ perspective. In the end, make sure what you're developing for them meets their needs, because this will benefit both the client and yourself.
