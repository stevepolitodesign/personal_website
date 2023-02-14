---
title: Pulling Data From Salesforce Into Drupal
tags: ["Salesforce", "Drupal"]
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
date: 2015-11-19
node: 152
---

In my last tutorial, we [integrated Salesforce with a local Drupal installation](/blog/integrate-salesforce-local-drupal-installation). In this tutorial, we will continue to build off from what we learned and pull data from Salesforce into Drupal.

For those of you who didn't read my last tutorial, I will repeat a few crucial steps needed to get us started.

## Create a Free Salesforce Developer Account

If you don't already have a Salesforce account, you can create a free developer account by following the steps below.

1. Go to [https://developer.salesforce.com/signup](https://developer.salesforce.com/signup) and apply for an account
2. Check your email for confirmation, and verify your account
3. You can now access your account by going to [https://login.salesforce.com/](https://login.salesforce.com/)

## Install and Enable Salesforce Suite Module

In order to connect your local Drupal install with your Salesforce account, you'll need to install and enable the [Salesforce Suite](https://www.drupal.org/project/salesforce) module.

![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-06-at-9.45.00-PM.png)

## Authenticate Your Salesforce Account With Drupal

In order to authenticate your Salesforce account with Drupal, you need to create a connected app in Salesforce. Follow these steps to create a connected app, and authenticate Salesforce with Drupal.

1. Login to your Salesforce account at [https://login.salesforce.com/](https://login.salesforce.com/)
2. Under **Build** Click **Create \> Apps**
3. Then under **Connected Apps** click **New**
   ![](/assets/images/posts/pulling-data-salesforce-drupal/connected-app.gif)\*\*
4. Fill out the following fields:
   1. Connected App Name
   2. API Name
   3. Contact Email
   4. Select Enable OAuth Settings
   5. The Callback URL will be [https://your-example-site/salesforce/oauth_callback](https://your-example-site/salesforce/oauth_callback). Note that you can find this at **admin/help/salesforce** on your local Drupal install
   6. Select **Perform requests on your behalf at any time** and add it to the **Selected OAuth Scopes** column
   7. I also needed to add **Full access (full)** to the **Selected OAuth Scopes** column  
      ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-06-at-8.47.03-PM.jpg)  
      ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-06-at-8.48.31-PM.jpg)
5. Save. You'll get a message alerting you that you app will be ready to authenticate within 2-10 minutes.  
   ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-06-at-8.44.48-PM.jpg)
6. In Salesforce under Quick Links click **Manage Apps**. Then under **Connected Apps** click the name of the app to see the **Consumer Key** and **Secret Key**  
   ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-06-at-9.34.23-PM.png)  
   ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-06-at-8.49-blur.jpg)
7. Back on your local Drupal install go to the Salesforce Authorization page at **admin/config/salesforce/authorize**
   1. ​Add your consumer and secret key  
      ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-06-at-8.51-blur.jpg)
   2. Under advanced, add the Salesforce endpoint. This will be the domain you see in your address bar when logged into your Salesforce account. In my case it's [https://na34.salesforce.com](https://na34.salesforce.com)  
      ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-06-at-8.51.22-PM.jpg)
   3. Click **Authorize** and follow the prompts

## Add Fields To A Drupal Entity That Will Be Populated From Salesforce Object

In order to pull data from Salesforce into Drupal, we need to create fields for the data mapping. For this tutorial, I'm going to use the default contacts that come with a [free Salesforce developer account](https://developer.salesforce.com/signup). Specifically, I'm going to use the **Salutation** , **First Name** , **Last Name** fields. I'm also going to create a custom content type to serve as the entity to map the data to.

![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-18-at-9.10.52-PM.png)

![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-18-at-9.11.19-PM.png)

1. Create a custom content type called Contacts by navigating to **admin/structure/types/add**  
   ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-18-at-9.20.34-PM.png)  
   ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-18-at-9.22.37-PM.png)
   1. ​Add a list(text) field for the Salutation. Add the following for default values (these are the default values used in Salesforce).
      1. Mr.
      2. Ms.
      3. Mrs.
      4. Dr.
      5. Prof.
   2. ​Add a text field for the First Name
   3. ​Add a text field for the Last Name  
      ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-18-at-9.26.54-PM.png)

## Enable Modules\*\*

Enable **Salesforce Mapping** and **Salesforce Pull**

![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-18-at-10.01.40-PM.png)

## Add a Salesforce Mapping

1. Navigate to **admin/structure/salesforce/mappings**
2. Select **Node** under **Drupal Entity Type**
3. Select **Contact** under **Drupal Entity Bundle**
4. Select **Contact** under **Salesforce object**

![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-18-at-9.31.47-PM.png)

## Map Salesforce Fields To Drupal Fields

Configure the following under the **FIELD MAP** section

1. Under the **DRUPAL FIELD** column, select **Properties** and then the fields we created earlier.
   1. I also mapped **Full Name** to the **Title** field.
2. Under the **SALESFORCE FIELD** column, select the Salesforce field that you wish to map to.
   1. ProTip: Use [Chosen](https://www.drupal.org/project/chosen) to help search the Salesforce fields.
3. Under the **DIRECTION** select **SF to Drupal** for all fields  
   ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-19-at-6.23.54-AM.png)
4. Under **Action triggers** select the following:
   1. Salesforce object create
   2. Salesforce object update
   3. Salesforce object delete  
      ![](/assets/images/posts/pulling-data-salesforce-drupal/Screen-Shot-2015-11-19-at-6.08.49-AM.png)
5. Save

## Batch Upload Data From Salesforce Into Drupal

Now that we've mapped our Salesforce fields with our Drupal fields, we can finally import data into Drupal. The simplest way to do this is to run cron. However, I ran into an issue where running cron simply didn't pull in any data. To fix this, you need to delete the `salesforce_pull_last_sync` variable.

- Run the following command

```text
drush vdel salesforce
```

- You will see an output similar to below. Enter the number that corresponds with the `salesforce_pull_last_sync` variable you wish to delete. If you're mapping more than one Salesforce Object, there will be more than one `salesforce_pull_last_sync` variable

```text
Enter a number to choose which variable to delete.
[0] : Cancel
[1] : salesforce_consumer_key
[2] : salesforce_consumer_secret
[3] : salesforce_endpoint
[4] : salesforce_identity
[5] : salesforce_instance_url
[6] : salesforce_pull_last_sync_Contact
[7] : salesforce_refresh_token
```

- Run cron

## Conclusion and Final Thoughts

I absolutely struggled connecting Salesforce and Drupal on my first project. The two main issues I ran into were the following:

1. I couldn't pull data into Drupal from Salesforce until I deleted the `salesforce_pull_last_sync` variable and ran cron
2. Fields need to be the same field type in Salesforce and Drupal. For example, text fields map to text fields. List fields maps to list fields.

Also, if you're importing a lot of data, you'll need to run cron multiple times. You also might run into timeout issues.
