---
title: Drupal Salesforce Not Updating Records [Solved]
tags: ["Tutorial", "Salesforce"]
categories: ["Drupal 7"]
date: 2015-12-05
node: 155
---

OK, so you've [integrated your Drupal install with Salesforce](/blog/integrate-salesforce-local-drupal-installation) and are able to [pull data from Salesforce into Drupal](/blog/pulling-data-salesforce-drupal). Everything's working perfectly, right? Well, if you're like me, then probably not. I noticed right away that I was running into and issue where Drupal was not updating records from Salesforce. In this tutorial, we're going to troubleshoot the issue and implement a solution using by checking the salesforce_pull SystemQueue.

## Check The salesforce_pull SystemQueue

Most likely the problem is that you have a huge queue that can't complete during a normal cron run. What's happening is that the data is being pulled from Salesforce into Drupal, but it's not actually being processed. It's just sitting in a queue that can't complete.

### Using drush

The first thing you need to do when Salesforce is not updating records in Drupal is to check the **SystemQueue.** Run the following drush command to check the SystemQueue, specifically looking for **salesforce_pull**.

```text
drush queue-list
```

Once you run the above command, look for the following output:

```text
salesforce_pull 1234 SystemQueue
```

If you get **0** for saleforce_pull, that means everything is up to date. If this is the case, and you're positive that records are not updating, make sure you've [integrated your Drupal install with Salesforce](/blog/integrate-salesforce-local-drupal-installation) and are able to [pull data from Salesforce into Drupal](/blog/pulling-data-salesforce-drupal).

Finally, if you're confident you're integrated with Salesforce, you might want to delete the **salesforce_pull_last_sync** variable and **run cron.** Run the following command to delete the **salesforce_pull_last_sync** variable.

```text
drush vdel salesforce
```

You will see an output similar to below. Enter the number that corresponds with the **salesforce_pull_last_sync** variable you wish to delete. If you're mapping more than one Salesforce Object, there will be more than one **salesforce_pull_last_sync** variable.

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

Finally, run cron.

### Using Queue UI

If you don't have drush installed on you're server, the above steps won't be much help. Luckily there's the [Queue UI](https://www.drupal.org/project/queue_ui) module, which allows you to check the status of **SystemQueues** as well as run cron or batch process them.

1. Install and enable the [Queue UI](https://www.drupal.org/project/queue_ui) module.

   ![](/assets/images/posts/drupal-salesforce-not-updating-records-solved/Screen-Shot-2015-12-04-at-9.13.18-PM.png)

2. Navigate to **admin/config/system/queue-ui**
3. Select **salesforce_pull**

   ![](/assets/images/posts/drupal-salesforce-not-updating-records-solved/Screen-Shot-2015-12-04-at-8.33.28-PM.png)

4. Click **Batch process**

However, even if you hit **Batch process** you still might not be able to process the whole queue because of a 504 Gateway Timeout.

## 504 Gateway Timeout Solution

For me, the main reason I was getting a huge queue that could never process was because I was running into timeouts. Depending on your server configuration, there are several ways to fix this. In my case, I needed to update my **/etc/nginx/nginx.conf** file and add the following line:

```text
proxy_read_timeout 3600;
```

I also adjusted the following setting in my **php.ini** file.

```text
max_input_time=3600
max_execution_time=3600
```

Once I increase these values to 3600 (3,600 seconds equals 1 hour), I was able to run through my salesforce_pull SystemQueue.
