---
title: Create a List Tab For Drupal Calendar
excerpt:
  Drupal’s Calendar module allows an easy way for site builders to display events
  in a month, week day and year format right out of the box. However, I recently
  needed to add an additional tab to the view display to list all upcoming
  events.
tags: ["Calendar", "Date", "Tutorial"]
categories: ["Drupal 7"]
resources:
  [{ title: "Calendar", url: "http://www.drupal.org/project/calendar" }]
date: 2016-04-27
node: 163
---

## Introduction and Requirements

Drupal's [Calendar module](https://www.drupal.org/project/calendar) allows an easy way for site builders to display events in a month, week day and year format right out of the box. However, I recently needed to add an additional tab to the view display to list all upcoming events. The requirements were that this would become the default display for the view, meaning that the list would display be default if user didn't supply any arguments to the URL. For example, if the user navigated to **example.com/events** they would see the list of all upcoming events instead of the month view. In order to follow along in this tutorial you will need a content type that is using a **Date** field with an **end date**. You will also need the [Calendar module](https://www.drupal.org/project/calendar) installed.

Below is what we will be creating.

![](/assets/images/posts/create-list-tab-drupal-calendar/final.gif)

> Note that the **All** tab displays first by default, and displays all upcoming events in a list.

## Create a Calendar From Template

1. Navigate to the Views configuration page **admin/structure/views** and click **Add view from template**

   ![](/assets/images/posts/create-list-tab-drupal-calendar/1.1.png)

2. Find the **Calendar** view that utilizes a **Date** field, and click **add.** In my case, my date field is called **field_date**.

   ![](/assets/images/posts/create-list-tab-drupal-calendar/1.2.png)

## Add a New Tab to the Calendar to List All Events

1. First, let's update the path for all the displays (Month, Week, Day and Year). By default it's set to use the field name. Let's update it to use **events.** Below are my final paths.

   1. **Month:** events/month
   2. **Week:** events/week
   3. **Day:** events/day
   4. **Year:** events/year

   ![](/assets/images/posts/create-list-tab-drupal-calendar/1.3.png)

2. Now we need to remove the **Month** view as the **Parent menu item**. Go to the **Month** view and click the **Tab: Month** link.

3. Select **Menu tab**. Configure the tab using the following info.

   ![](/assets/images/posts/create-list-tab-drupal-calendar/1.4.png)

   | **Title** | **Description** | **Menu**   | **Weight** |
   | --------- | --------------- | ---------- | ---------- |
   | Month     | Leave Blank     | Navigation | 0          |

4. Add a new **page**.

   ![](/assets/images/posts/create-list-tab-drupal-calendar/1.5.png)

5. Set the path to **events/all**

   ![](/assets/images/posts/create-list-tab-drupal-calendar/1.6.png)

6. Under **Menu:** set the **type** to **Default menu tab** and click **Apply**

   ![](/assets/images/posts/create-list-tab-drupal-calendar/1.7.png)

7. On the next screen, configure the tab using the following info.

   | **Parent menu item** | **Title** | **Description** | **Menu**    |
   | -------------------- | --------- | --------------- | ----------- | ---------- |
   | Normal menu item     | Events    | Navigation      | Leave Blank | Navigation |

8. Under **Format** change the format from **Calendar** to **Unformatted list.** Make sure to to select **This page (override).**

   ![](/assets/images/posts/create-list-tab-drupal-calendar/1.9.png)

9. Under **Format** show **fields.** Make sure to to select **This page (override).**

   ![](/assets/images/posts/create-list-tab-drupal-calendar/1.10.png)

10. Under **FILTER CRITERIA** add **Date: Date (node)**

    ![](/assets/images/posts/create-list-tab-drupal-calendar/1.11.png)

11. One the next screen, leave all the defaults. Select the **start date** field of the date field you are displaying in the calendar views.

    ![](/assets/images/posts/create-list-tab-drupal-calendar/1.12.png)

12. One the next screen set the **Operator** to **Is greater than or equal to** the **Relative** date of **12AM today**.

    ![](/assets/images/posts/create-list-tab-drupal-calendar/1.13.png)

13. **Save** the view.
