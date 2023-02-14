---
title: Install Drupal Memcached on a Media Temple DV Server
tags: ["Tutorial", "Performance"]
categories: ["Drupal 7"]
resources:
  [
    {
      title: "Memcache API and Integration",
      url: "https://www.drupal.org/project/memcache",
    },
    { title: "Memcached", url: "http://memcached.org/" },
  ]
date: 2015-12-06
node: 156
---

Site performance is crucial to a good user experience, and also is a factor in SEO. Because Drupal sites can be very query heavy at times, their performance can suffer. Luckily, there are a few caching libraries than can solve this problem and help increase performance. In this tutorial we're going to install the [Memcached](http://memcached.org/) library on a Media Temple DV Server, as well as configure the [Memcache API and Integration](https://www.drupal.org/project/memcache) module.

Memcached is described as a...

> **Free & open source, high-performance, distributed memory object caching system** , generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load.
>
> Memcached is an in-memory key-value store for small chunks of arbitrary data (strings, objects) from results of database calls, API calls, or page rendering.

## Backup Your Server

Full disclosure, I'm not a server guy. I know basic server configuration settings, and how to navigate the server through the command line. The next steps worked for me, but becuase I'm not a server expert, I recommend you make a full backup of your server before you continue on with this tutorial.

## Install Memcached on a Media Temple DV Server

If you're like me, you probably searched "How to install Memcached on a Media Temple DV Server" and found several results. Unfortunately for me, none of them worked. Again, I'm not a server guy, so I can't blame the authors as they did provided very details instructions. It was just that I ran into issues where I couldn't install a certain library, or copy a directory because of they way my server is set up.

> Finally, after a lot of searching I stumped upon [nLightened Development's](http://www.nlighteneddevelopment.com/) excellent [post](http://www.nlighteneddevelopment.com/content/installing-apc-memcached-and-varnish-media-temple-dv-level-4-centos-65) titled Installing APC Memcached and Varnish on Media Temple DV Level 4 Centos 6.5. I want to give the author(s) of that post full credit for the commands I used to install Memcached on a Media Temple DV Server.

1. The first you will need to do is [enable root access](https://mediatemple.net/community/products/dv/204643780/how-do-i-enable-root-access-to-my-dv) on your Media Temple DV server.
1. Next, you need to ssh into your server. To do that, run `ssh root@yourdomain.com`
1. You'll be prompted for your password with something like `root@yourdomain.com's password:`. You will not see your password being entered when you type it, so it's helpful to copy and paste. Hit enter.
1. Once logged in enter `cd ~` to ensure you're in the home directory.
1. Finally, run the following commands. Again, this is from [nLightened Development's](http://www.nlighteneddevelopment.com/) excellent [post](http://www.nlighteneddevelopment.com/content/installing-apc-memcached-and-varnish-media-temple-dv-level-4-centos-65) titled Installing APC Memcached and Varnish on Media Temple DV Level 4 Centos 6.5

   ```text
   yum install Memcached
   vim /etc/sysconfig/memcached

   PORT="11211"
   USER="memcached"
   MAXCONN="1024"
   CACHESIZE="64"
   OPTIONS="-l 127.0.0.1"

   chkconfig --add memcached
   cd /usr/local/src/
   wget http://pecl.php.net/get/memcache
   tar -xvf memcache
   cd memcache-3.0.8/
   /usr/bin/phpize
   ./configure -enable-memcache
   make
   make install
   echo “extension=memcache.so” > /etc/php.d/memcache.ini
   service httpd restart
   ```

1. Confirm memcache is installed by running `telnet localhost 11211`
1. You should get something similar to the following

   ```text
   Trying ::1...
   telnet: connect to address ::1: Connection refused
   Trying 127.0.0.1...
   Connected to localhost.
   Escape character is '^]'.
   ```

1. Then run the following `stats`
1. If everything is setup correctly, you'll get an output similar to the following

   ```text
   STAT pid 518
   STAT uptime 362776
   STAT time 1449610483
   STAT version 1.4.4
   STAT pointer_size 64
   STAT rusage_user 8.143761
   STAT rusage_system 11.669226
   STAT curr_connections 5
   STAT total_connections 956
   STAT connection_structures 20
   STAT cmd_get 122913
   STAT cmd_set 29485
   STAT cmd_flush 0
   STAT get_hits 106004
   STAT get_misses 16909
   STAT delete_misses 1973
   STAT delete_hits 4647
   STAT incr_misses 0
   STAT incr_hits 0
   STAT decr_misses 0
   STAT decr_hits 0
   STAT cas_misses 0
   STAT cas_hits 0
   STAT cas_badval 0
   STAT auth_cmds 0
   STAT auth_errors 0
   STAT bytes_read 144024662
   STAT bytes_written 359296232
   STAT limit_maxbytes 67108864
   STAT accepting_conns 1
   STAT listen_disabled_num 0
   STAT threads 4
   STAT conn_yields 0
   STAT bytes 9615683
   STAT curr_items 5094
   STAT total_items 29485
   STAT evictions 0
   END
   ```

## Edit php.ini

Now that memcached is installed on your server, you'll need to edit your domain specific php.ini file. Since we're dealing with a Media Temple DV, you can simply follow these steps to [edit your domain specific php.ini file](https://mediatemple.net/community/products/dv/204403894/how-can-i-edit-the-php.ini-file).

1. Once on the **PHP Settings** page, scroll to the **Additional directives** section and add the following lines.

   ```text
   extension=memcache.so
   memcache.hash_strategy="consistent"
   ```

   ![](/assets/images/posts/install-drupal-memcached-media-temple-dv-server/Screen-Shot-2015-12-06-at-9.05.38-AM.png)

   If this doesn't work, you might need to also edited you global php.ini file, but I don't believe this is necessary.

   ```sh
   cd ~
   nano /etc/php.ini
   ```

2. Then add the following

   ```text
   extension=memcache.so
   memcache.hash_strategy="consistent"
   ```

3. Finally, restart the server by running `/etc/init.d/httpd restart`

## Install and Enable the Drupal Memcache API and Integration Module

1. Put your site in maintenance mode by going to **admin/config/development/maintenance**
1. Install and enable [Memcache API and Integration](https://www.drupal.org/project/memcache)

   ![](/assets/images/posts/install-drupal-memcached-media-temple-dv-server/Screen-Shot-2015-12-08-at-4.27.32-PM.png)

## Edit Drupal's settings.php

1. Add the following to your **settings.php** file

   ```php
   $conf["cache_backends"][] = "sites/all/modules/memcache/memcache.inc";
   $conf["cache_default_class"] = "MemCacheDrupal";
   $conf["cache_class_cache_form"] = "DrupalDatabaseCache";
   $conf["memcache_servers"] = ["127.0.0.1:11211" => "default"];
   $conf["memcache_bins"] = ["cache" => "default"];
   ```

2. Take your site back online by going to **admin/config/development/maintenance**
