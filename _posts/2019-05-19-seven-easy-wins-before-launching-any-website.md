---
title: Seven Easy Wins Before Launching Any Website
categories: ["Web Development"]
resources:
  [
    { title: "axe", url: "https://www.deque.com/axe/" },
    {
      title: "Lighthouse",
      url: "https://developers.google.com/web/tools/lighthouse/",
    },
    {
      title: "Integrity",
      url: "https://peacockmedia.software/mac/integrity/free.html",
    },
    { title: "Simple Site Status", url: "https://www.simplesitestatus.com/" },
  ]
date: 2019-05-19
---

I work for an agency that specializes in developing small to medium sized websites. Over the years I've found that I follow the same process when launching each website. This list isn't comprehensive, but I'm confident that it's applicable to any site launch.

## 1. Run an Accessibility Audit Against Each Unique Page Template

Ensuring a website is accessible is often overlooked unfortunately. Accessibility is more than just ensuring images have alt tags, and that a user can tab through the website easily. There are other considerations such as color contrast and page markup. Luckily you don't need to remember all these rules thanks to [axe](https://www.deque.com/axe/). This browser extension will highlight any accessibility infractions when run against a particular page. I recommend running the audit on all unique page templates before site launch. For example, if you're building a WordPress site, you should test the following templates:

1. Front Page
1. Blog Page
1. Archive
1. 404
1. Search
1. Single Post

Below is an audit run on this site. Looks like I have some color contrast issues.

![axe audit](/assets/images/posts/seven-easy-wins-before-launching-any-website/1.1.png)

## 2. Run a Lighthouse Audit Against Each Unique Page Template

In an effort to improving the quality of web pages, Google has created [Lighthouse](https://developers.google.com/web/tools/lighthouse/). It exposes any areas where improvements can be made, along with their recommendations. I run this tool against all unique page templates before going live. For example, if you're building a WordPress site, you should test the following templates:

1. Front Page
1. Blog Page
1. Archive
1. 404
1. Search
1. Single Post

Below is an audit run on this site. My site scores very well due in part to the fact that it's built in [Gatsby](https://www.gatsbyjs.org/).

![lighthouse audit](/assets/images/posts/seven-easy-wins-before-launching-any-website/2.1.png)

It can be difficult to increase scores in all areas depending on your site's architecture. I recommend running these audits during development to catch any issue before it's too late.

## 3. View Each Unique Page Template At Each Breakpoint

Most web developers have the luxury of working on large monitors. This makes it easy to overlook design issues on smaller devices. I find it's helpful to check each unique page template at each breakpoint, as well as each breakpoint -1px. This helps catch edge cases.

For example. my site's breakpoints are `1200px`, `992px` and `768px`. This means I test each unique page template at those breakpoints, as well as `1199px`, `991px` and `767px`. Below is what that looks like.

![breakpoint test](/assets/images/posts/seven-easy-wins-before-launching-any-website/3.1.gif)

## 4. Check for Broken Links

This is easy but often overlooked. I use [Integrity](https://peacockmedia.software/mac/integrity/free.html), but there are other link checking tools out there. **Protip:** If you're redeveloping an existing website, don't forget to handle redirects if the URL structure changes. Otherwise you will have a lot of broken links.

Below is a sample of some broken links on my site. It's not uncommon that external links can break overtime. However, you'll want to check for any internal linking errors.

![a list of broken links found by integrity](/assets/images/posts/seven-easy-wins-before-launching-any-website/4.1.png)

## 5. Document Everything in a README File

Save other developers or your future self time and effort be documenting **EVERYTHING** in a README file. Get in the habit of doing this as you're writing code. Some things that may seam obvious are not, especially if you don't work on the project for months. Below is a list of items I always document. **Make sure to NEVER store any sensitive data in the README file**

1. Local development notes
1. Deployment notes
1. Hosting notes
1. External API notes
1. Any gotchas, edge cases, or bugs
1. A list of to dos
1. Domain, SSL and DNS notes

Below is a README for a live project that I am working on. Note that I changed some data for privacy reasons.

```md
## To Do

- [] Might need to remove the Historical Site field since this is now a category

---

## Notes

### Redirector Template

In order to keep the parent child relationship between pages, while allowing links to point off site, I created a custom template at `wp-content/themes/example/custom-template-redirector.php`. This will redirect that page to a specified URL served by ACF.

### Blog and News

- The blog shows all posts, except those categorized as **News** and **Uncategorized**. This is done by overriding the query in `wp-content/mu-plugins/custom-queries.php`
- The homepage only displays posts that are categorized as **News**
- Created `wp-content/themes/example/custom-template-news.php` to redirect to the **News Archive**

### Custom Search Pages

The following was added in order to allow a user to search for listings based on town.

- Added `wp-content/mu-plugins/custom-query-vars.php` to allow the `location_town_id` parameter to parsed from the URL.
  - EX. http://localhost:3000/listing-category/historical-sites/?location_town_id=206
- Added `wp-content/mu-plugins/custom-queries.php` to override any default queries, and to use `location_town_id` in the custom queries.

### Listing Archive

The **listing** post type has `'has_archive'` set to `false`. In order to display the archive, I created a custom template at `wp-content/themes/example/archive-listing.php`.

### Weather

In order to fetch weather data, I needed to do the following. [More info can be found at the rep](https://github.com/BrookeDot/SimplerWeather#proxy-example)

- Create a proxy to fetch the data. This is stored at `wp-content/themes/example/proxy.php`
  - I then created a page with the url `/proxy/` that loads this template.

### Event Archive Interior Images

In order to allow a user to have control over the interior banner on events archive pages, I did the following.

1. Set the **Events template** to **Default Events Template** at `/wp-admin/edit.php?post_type=tribe_events&page=tribe-common&tab=display`
1. Add an image with its size set to **large** to **Add HTML before event content** at `/wp-admin/edit.php?post_type=tribe_events&page=tribe-common&tab=display`
1. Conditionally show the content from **Add HTML before event content** in `wp-content/themes/example/tribe-events/default-template.php`
1. Instantiate a new `interiorImage()` class in `wp-content/themes/example/assets/js/custom/interiorImage.js`

### Shortcodes

All shortcodes are located in `wp-content/mu-plugins/custom-shortcodes.php`

- `[menu_ad text="ad text" image-id="185"]`
  - This is used to display an ad in the main menu
    - This only works becuase of the [shortcode-in-menus plugin](https://wordpress.org/plugins/shortcode-in-menus/)
    - User needs to add `menu-ad__link` class to link
  - The `text` attribute is used to display the the ad text
  - The `image-id` attribute is used to fetch media from the library and display in the ad
    - You will need to upload the media to the library first. This is needed to get the ID

### Layout

- Using [Semantic UI Container](https://semantic-ui.com/elements/container.html)
- Using [Semantic UI Grid](https://semantic-ui.com/collections/grid.html)

---

## Repository

- Hosted at BitBucket under **user@example.com**.
- `git clone https://example@bitbucket.org/example/example.git`

---

## Local Development

Using [WPGulp](https://github.com/ahmadawais/WPGulp)

1. `cd wp-content/themes/example`
1. `npm i`
1. `npm start`

---

## APIs

### DarkSky

- Under **user@example.org**

### Google Analytics

- UA-12345678-9

### Google Maps API

- Under **user@example.org**

### SendGrid

- Under **user@example.org**

### reCATCHA

- Under **user@example.com**

### JetPack

- Under **user@example.com**
```

## 6. Setup Downtime Monitoring

Don't make the assumption that just because your site is running smoothly before launch that it will continue to stay running smoothly forever. If you're running a WordPress site, just install [JetPack](https://jetpack.com/) and enable downtime monitoring. It's free and very effective. If you're not running a WordPress install, you can use something like [Simple Site Status](https://www.simplesitestatus.com/). Full disclosure, I built this app and it's still in beta.

## 7. Install Some Type of Analytics Tracking

Whether you're building a personal project, or something for a client, you need to track metrics such as unique page visits, page views and time on site. Even if you or your client doesn't care about these metrics early on, set up something just in case. The obvious choice is [Google Analytics](https://analytics.google.com/analytics/web/), but [Dave Ruppert makes a good case](https://daverupert.com/2019/04/goodbye-google-analytics-hello-fathom/) to try [Fathom](https://usefathom.com/). Whatever you chose, chose something.
