---
title: Dynamically Link to Each Month In Drupal's Calendar
tags: ["Tutorial", "Calendar", "Menus"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Calendar", url: "https://www.drupal.org/project/calendar" },
    { title: "Menu Token", url: "https://www.drupal.org/project/menu_token" },
    {
      title: "Views Menu Area",
      url: "https://www.drupal.org/project/views_menuarea",
    },
  ]
date: 2016-06-22
node: 168
---

## Introduction and Requirements

Drupal's [Calendar](https://www.drupal.org/project/calendar) module allows you to page between months. However, it can be frustrating for a user to have to page several months in either direction if they know what month they want to view. For example, if the current month is June but a user wants to see upcoming events in December, they would need to click through 5 times. In this tutorial, we are going to solve this problem by creating a menu where each menu item will link to each month. As an added bonus, we will make sure that the menu updates annually by using [Menu Tokens.](https://www.drupal.org/project/menu_token)

![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/final-calendar-links.gif)

> The above image demonstrates how a user can easily navigate between months.

## Enable Necessary Modules

- [Calendar](https://www.drupal.org/project/calendar)
- [Date](https://www.drupal.org/project/date)
- [Entity API](https://www.drupal.org/project/entity)
- [Menu Token](https://www.drupal.org/project/menu_token)
- [Token](https://www.drupal.org/project/token)
- [Views](https://www.drupal.org/project/views)
- [Views Menu Area](https://www.drupal.org/project/views_menuarea)
- Views UI

## Configure Your Calendar's Paths

Before we can create a dynamic link for each month in Drupal's calendar, we need to set up the path structure for the month view of the calendar. In this tutorial, we will create a brand new calendar, but you can use an existing calendar as well.

1. Navigate to the Views configuration page **admin/structure/views** and click **Add view from template**

![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/1.1.png)

2. Find the **Calendar** view that utilizes a **Date** field, and click **add.** In my case, my date field is called **field_date**.

![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/1.2.png)

3. Update the path for all the displays (Month, Week, Day and Year). By default it's set to use the field name. Let's update it to use **events**. Below are my final paths.

   1. **​Month:** events/month
   2. **​Week:** events/week
   3. **​Day:** events/day
   4. **​Year:** events/year

   ![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/1.3.png)

## Create a New Menu and Dynamically Link to Each Month

1. Create a new menu by navigating to **/admin/structure/menu/add**, and call it **Calendar**

![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/2.1_2.png)

2. Add a new link to the calendar for January by navigating to **/admin/structure/menu/manage/menu-calendar/add**
3. Configure the link as follows:
   1. **Path** = events/[current-date:custom:Y-01]
   2. **Use tokens in title and in path** = enabled
   3. Save

![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/2.2_0.png)

> At the time of this writing, you need to save the menu link **twice**. The first save will result in a broken link, as seen below. I have opened an [issue with Menu Token](https://www.drupal.org/node/2753499) regarding this.

![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/Screen-Shot-2016-06-23-at-3.56.42-PM.png)

Repeat this process for all twelve months. The only item you need to change in the link is the month. For example, January is **events/current-date:custom:Y-01** and February is **events/[current-date:custom:Y-02]**.

![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/2.4_0.png)

## Add The New Menu To Your Month View (Optional)

The next two steps are optional. Since we have a menu, you could simply add the menu's block to a region, and even specify to only have it appear on the calendar page. However, we can add the menu directly to the view using [Views Menu Area](https://www.drupal.org/project/views_menuarea).

1. Navigate back to the calendar view we created in the first part of this tutorial. On the **Month** view, under **HEADER** add **Global: Menu area**

![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/3.1_0.png)

2. Under **Select menu** select **Calendar**

![](/assets/images/posts/dynamically-link-each-month-drupals-calendar/3.2_0.png)

3. Save the view

## Apply Patch To Views Menu Area

If you were to navigate to your the month view of your calendar, you might get the following error:

> Strict warning: Only variables should be passed by reference in views_handler_area_menu-\>render() (line 32 of/calendar-links/sites/all/modules/views_menuarea/views_handler_area_menu.inc).

Luckily, [this issue](https://www.drupal.org/node/2475063) has been resolved with [this patch](https://www.drupal.org/files/issues/views_menuarea_only_vars_should_be_passed_as_reference.patch). Follow the commands below to fix this bug.

    cd sites/all/modules/views_menuarea
    patch -p1 < views_menuarea_only_vars_should_be_passed_as_reference.patch
    rm views_menuarea_only_vars_should_be_passed_as_reference.patch

## Conclusion and Next Steps

You could take what we learned here and apply the same concepts to the week and day views as well. Also, you don't need to make a totally new menu for the calendar links (unless you want to embed them on the view). You could add these links to any existing menu on your site.
