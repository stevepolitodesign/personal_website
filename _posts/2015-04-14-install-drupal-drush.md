---
title: Install Drupal with drush
tags: ["Quick Tip", "drush"]
categories: ["Drupal 7"]
resources: [{ title: "drush", url: "http://docs.drush.org/en/master/install/" }]
date: 2015-04-14
node: 138
---

Last week I wrote an article about [how to use the command line](/blog/how-easily-change-directories-terminal). Now we're going to put this knowledge to use. Using [drush](http://www.drush.org/) you can set up a fresh Drupal install in seconds.

The first thing you are going to want to do is [install drush](https://drupalize.me/videos/installing-drush-composer?p=1156). Once you have drush installed you only need to run two commands.

First, navigate to the directory you wish to unpack a new Drupal install. In my example I `cd` into the **Demo** directory. This means that a new directory will be created here.

![](/assets/images/posts/install-drupal-drush/spd-drush-cd.gif)

Once inside the directory, run the following command:

    drush dl drupal --drupal-project-rename=example

This command downloads the latest stable version of Drupal into a directory called **example**. So, in my example I am in the **DEMOS** directory which now contains a new directory called **example**.

![](/assets/images/posts/install-drupal-drush/spd-drush-drupal-dl.gif)

Now that we've downloaded Drupal, we need to configure the database. In my case, I am working locally using [MAMP](https://www.mamp.info/en/). MAMP's default server settings are as follows:

| Database Driver | Database Username | Database Password | Database Host | Database Port |
| --------------- | ----------------- | ----------------- | ------------- | ------------- |
| mysql           | root              | root              | localhost     | 21            |

However, if you are doing this on a live server then you will need to check with your host for these settings.

The first thing we need to do is `cd` into the new directory we just created since we are still in its parent directory. In my example I need to do the following.

    cd example

Then, run the following command.

    drush si --db-url=mysql://[db_user]:[db_pass]@localhost/[db_name]

You will need to replace the following with your own credentials​

`[db\_user]` is the database username. In my case it's **root**.
`[db\_pass]` is the database password. In my case it's **root**.  
`[db\_name]` is the database name. This will be created through the command. In my example it's **drush-example**.

![](/assets/images/posts/install-drupal-drush/spd-drush-si.gif)

This will then automatically create a superuser account. I recommend changing the username afterwards for security reasons.
