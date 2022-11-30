---
title: Configure Cloudflare DNS to Work with Netlify
categories: ["Netlify"]
tags: ["DNS", "Cloudflare"]
resources: [{
    title: "Cloudflare",
    url: "https://www.cloudflare.com/"
},{
    title: "Netlify",
    url: "https://www.netlify.com/"  
}]
date: 2018-11-21
---

I just migrated my site to [Netlify](https://www.netlify.com/) but wanted to keep my DNS with [Cloudflare](https://www.cloudflare.com/). Below are the steps needed to configure Cloudflare DNS to Work with Netlify.

## 1. Add WWW and Non WWW Domains to Netlfiy

Make sure you add both the **WWW** and **Non WWW** versions of your domain. In my case, that meant adding **www.stevepolitodesign.com** and **stevepolitodesign.com**

![Domain settings for stevepolitodesign.com](/assets/images/posts/configure-cloudflare-dns-to-work-with-netlify/steve-polito-design-domain-settings.png)

## 2. Make Note of Netlify's DNS Configuration

After you add your domain(s), you'll notice a **Check DNS configuration** button for each domain added.

![Check DNS configuration](/assets/images/posts/configure-cloudflare-dns-to-work-with-netlify/dns-configuration.png)

Click each button to reveal the settings. You'll notice that the settings for the **WWW** domain just list one option. It will list `www CNAME your-netlify-account.netlify.com.`.

However, you'll get two DNS recommendations for the **Non WWW** domain, which will look like this:

![Netlify DNS Recommendations](/assets/images/posts/configure-cloudflare-dns-to-work-with-netlify/netlify-www-dns-recommendations.png)

Note that Netlify recommends you avoid adding an A record.

## 3. Update Cloudflare DNS, and Disable Cloudflare CDN

Login to Cloudflare and make sure you have two **CNAME** records. One for the **WWW**, and one for the domain itself. There should be no A records.

Finally, disable Cloudflare's CDN by clicking the orange cloud next to these records. It should now be gray.

![Cloudflare DNS Setup](/assets/images/posts/configure-cloudflare-dns-to-work-with-netlify/cloudflare-dns-setup.png)