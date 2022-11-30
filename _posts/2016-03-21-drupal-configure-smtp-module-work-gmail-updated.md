---
title: Drupal Configure SMTP Module to Work with Gmail [Updated]
tags: ["Gmail", "SMTP", "Email", "Tutorial"]
categories: ["Drupal 7"]
resources: [{title: "SMTP Authentication Support", url: "http://www.drupal.org/project/smtp"}, {title: "Google Unlock Captcha", url: "https://accounts.google.com/DisplayUnlockCaptcha"}, {title: "Google Security Settings", url: "https://myaccount.google.com/security"}]
date: 2016-03-21
node: 161
---
 

At this point, there have been many great tutorials written about configuring Drupal's SMTP Authentication Support with Gmail. However, these tutorials are out dated, and do not take into account Google's added security settings. In this tutorial I'll show you how to configure Drupal's SMTP Authentication Support module and update Gmail's security setting.

## Install and Configure SMTP Module

1. Install the [SMTP Authentication Support](https://www.drupal.org/project/smtp) module in the usual way.

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-20-at-7.58.57-AM.png)

2. Navigate to the configuration page **admin/config/system/smtp**
3. Under **Turn this module on or off**  select **On**. You can leave **Send mail by queue**  and **Retry sending mail on error** deselected by default, but selecting them won't affect Gmail.

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-20-at-8.01.57-AM.png)

4. Under **SMTP server**  enter the following  **smtp.gmail.com.** Leave  **SMTP backup server** blank

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-20-at-8.06.44-AM.png)

5. Under  **SMTP port**  enter  **587**

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-20-at-8.06.51-AM.png)

6. Under  **Use encrypted protocol**  select **Use TLS**

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-20-at-8.06.57-AM.png)

7. Under  **SMTP AUTHENTICATION**  enter a Gmail address and password.

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-21-at-7.39.48-AM.jpg)

8. Under **E-MAIL OPTIONS**  use the same Gmail address as you did above and enter an  **E-mail from name**

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-21-at-7.40.29-AM.jpg)

9. Click Save

## Update Gmail Account Settings

1. Login to your Gmail account at [https://myaccount.google.com/](https://myaccount.google.com/)
2. On the account homepage, click  **Sign-in & security** or navigate to [https://myaccount.google.com/security](https://myaccount.google.com/security)

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-21-at-7.48.41-AM.png)

3. Scroll down to the  **Allow less secure apps:**  widget, and have it enabled.

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-21-at-7.51.35-AM.png)

4. Now navigate to [https://accounts.google.com/DisplayUnlockCaptcha](https://accounts.google.com/DisplayUnlockCaptcha) and click  **Continue**

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-21-at-7.53.40-AM.png)

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-21-at-7.53.47-AM.png)

5. Go back to the SMTP configuration page at **admin/config/system/smtp**
6. Enter an email address you would like to receive a test message from and click  **Save configuration**

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-21-at-7.55.17-AM.jpg)

7. Check your inbox to confirm you received the test message.

![](/assets/images/posts/drupal-configure-smtp-module-work-gmail-updated/Screen-Shot-2016-03-21-at-7.55.55-AM.png)
