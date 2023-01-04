---
title: Drupal Unable to send e-mail on BlueHost Server
tags: ["BlueHost", "Debugging"]
categories: ["Drupal 7"]
date: 2015-03-17
node: 134
---

With the launch of this new site, I encountered a very frustrating error. Drupal was unable to send emails, and I was receiving the following error message:

> Unable to send e-mail. Contact the site administrator if the problem persists.

This is a big problem because it means that users cannot register for accounts or recover their passwords. It also meant that I wouldn’t be able to receive form submissions or security related emails.

Admittedly, my set up is a little clunky. My site is hosted at BlueHost, but my email is being served from Zoho. The site is registered through GoDaddy, but the zone files are at WebHosting Pad. However, I was still getting email, so I knew that my zone files and MX records were configured correctly.

After chatting with support, we though we had a solution. There was no php.ini file on the server. This file is used for sending emails, among other things. To make sure the file took, I signed up to receive email updates on my blog with my Gmail account. Everything worked fine. However, the victory was short lived.

To test further, I tried to reset my password. No luck. This was frustrating because this is a core functionality of Drupal, unlike the opt-in form. Sometimes contributed modules have a hard time sending mail, but not Drupal itself.

I had run into this issue before with BlueHost, and the solution was to create an email address ending in my site’s domain on their end. Even though this address wouldn’t actually work since my mail servers are at Zoho, I created a throwaway account. Still no luck. This was puzzling to me because I was using this throw away email address as my site’s admin email under **admin/config/system/site-information**.

Just to test things more, I signed up for an account with a different email address. Success. I received the email from the throw away account in a matter of seconds. Ok, so the site can send emails, but just not to anything with @stevepolitodesign. The problem wasn’t with the throw away account, but with the email I’m using for my personal account. It ends in **@stevepolitodesign**.

Once I recreated that account on BlueHost, I was able to receive emails from the site.

**TLDR: If you receive this message “Unable to send e-mail. Contact the site administrator if the problem persists.” and you’re hosting at BlueHost but host mail elsewhere, create ALL email addresses on the site that end in your site’s domain on BlueHost’s end.**
