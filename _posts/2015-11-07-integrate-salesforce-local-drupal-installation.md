---
title: Integrate Salesforce With Local Drupal Installation
tags: ["Salesforce", "SSL", "Tutorial"]
categories: ["Drupal 7"]
resources:
  [
    {
      title: "Salesforce Suite",
      url: "https://www.drupal.org/project/salesforce",
    },
    {
      title: "Salesforce Developer Account",
      url: "https://developer.salesforce.com/signup",
    },
  ]
date: 2015-11-07
node: 151
---

[Salesforce](http://www.salesforce.com/) is one of the most popular CRMs used today. In this tutorial we will integrate Salesforce with a local Drupal install in order to access the Salesforce API. This will allow us to map data between Salesforce and Drupal.

## Enable SSL Certificate In MAMP

The [Salesforce Suite](https://www.drupal.org/project/salesforce) requires an SSL certificate to connect Salesforce with Drupal. Luckily, generating an SSL certificate is easy to do in MAMP.

1. First add a new host by clicking the "+" icon. Make sure to **enable SSL**![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-6.49.31-PM.jpg)
2. Next, click the SSL tab for the new host your created. Click the **Create self-signed certificate** button. ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-6.45.23-PM.jpg)
3. Fill out the prompt with whatever info you wish. You don't need to use real information. Click **Generate.** ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-6.46.00-PM.jpg)
4. You'll be prompted to select a destination to save the certificate. I chose to save mine at the root level of my project, but you can save it anywhere. ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-6.46.27-PM.jpg)

## Disable SSL Warning in Chrome (Optional)

You can now visit your site at [https://your-example-site](https://your-example-site). However, you'll notice that Google Chrome warns you the certificate is not trusted and the connection is not private. Since this is just a local site, this isn't an issue, but it can be really annoying. Follow the steps below to disable the SSL warning in Chrome.

![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-6.53.09-PM.jpg)

1. Click the lock icon in the upper left hand corner of the browser
2. Click certificate information
3. Click and drag the certificate onto your desktop ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/ssl-chrome.gif)
4. Double click the certificate to open **Keychain Access**
5. Make sure you are in the **System** section under the **Keychains** column on the left hand side
6. Drag your certificate into this area. You will be prompted to enter your password.
7. Enter your password and click **Modify Keychain** ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/ssl-chrome-2.gif)
8. Right click the certificate and click **Get Info**
9. Under **Trust** select **Always Trust** next to **When using this certificate:** and close out of the box.
10. You'll be prompted to enter your password. Once done, click **Update Settings** ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/ssl-chrome-3.gif)

You're now able to access your site without issue.

## Create a Free Salesforce Developer Account

If you don't already have a Salesforce account, you can create a free developer account by following the steps below.

1. Go to [https://developer.salesforce.com/signup](https://developer.salesforce.com/signup) and apply for an account
2. Check your email for confirmation, and verify your account
3. You can now access your account by going to [https://login.salesforce.com/](https://login.salesforce.com/)

## Install and Enable Salesforce Suite Module

In order to connect your local Drupal install with your Salesforce account, you'll need to install and enable the [Salesforce Suite](https://www.drupal.org/project/salesforce) module.

![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-9.45.00-PM.png)

## Authenticate Your Salesforce Account With Drupal

In order to authenticate your Salesforce account with Drupal, you need to create a connected app in Salesforce. Follow these steps to create a connected app, and authenticate Salesforce with Drupal.

1. Login to your Salesforce account at [https://login.salesforce.com/](https://login.salesforce.com/)
2. Under **Build** Click **Create** \> **Apps**
3. Then under **Connected Apps** click **New** ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/connected-app.gif)
4. Fill out the following fields:
   1. Connected App Name
   2. API Name
   3. Contact Email
   4. Select Enable OAuth Settings
   5. The Callback URL will be [https://your-example-site/salesforce/oauth_callback](https://your-example-site/salesforce/oauth_callback). Note that you can find this at **admin/help/salesforce**on your local Drupal install
5. Select **Perform requests on your behalf at any time** and add it to the **Selected OAuth Scopes** column
6. I also needed to add **Full access (full)** to the **Selected OAuth Scopes** column ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-8.47.03-PM.jpg) ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-8.48.31-PM.jpg)
7. Save. You'll get a message alerting you that you app will be ready to authenticate within 2-10 minutes. ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-8.44.48-PM.jpg)
8. In Salesforce under Quick Links click **Manage Apps**. Then under **Connected Apps** click the name of the app to see the **Consumer Ke** y and **Secret Key** ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-9.34.23-PM.png) ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-8.49-blur.jpg)
9. Back on your local Drupal install go to the Salesforce Authorization page at **admin/config/salesforce/authorize**
   1. ​Add your consumer and secret key ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-8.51-blur.jpg)
   2. Under advanced, add the Salesforce endpoint. This will be the domain you see in your address bar when logged into your Salesforce account. In my case it's [https://na34.salesforce.com](https://na34.salesforce.com) ![](/assets/images/posts/integrate-salesforce-local-drupal-installation/Screen-Shot-2015-11-06-at-8.51.22-PM.jpg)
   3. Click **Authorize** and follow the prompts

## Next Steps

Now that you've connected Salesforce with Drupal, you're ready to take advantage of the Salesforce API. The [Salesforce Suite](https://www.drupal.org/project/salesforce) module comes with additional sub modules to help you sync data with your Drupal site and Salesforce. You can also download the [Salesforce Webforms](https://www.drupal.org/project/salesforce_webforms) module to add additional features between Salesforce and Drupal.
