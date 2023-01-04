---
title: Display a Calendar On Taxonomy Pages In Drupal
tags: ["Calendar", "Date", "Taxonomy"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Calendar", url: "https://www.drupal.org/project/calendar" },
    { title: "Date", url: "https://www.drupal.org/project/date" },
    {
      title: "Taxonomy Display",
      url: "https://www.drupal.org/project/taxonomy_display",
    },
    { title: "Pathauto", url: "https://www.drupal.org/project/pathauto" },
  ]
date: 2016-05-14
node: 165
---

## Introduction and Requirements

Let's say you have a content type with a date field and term reference field. This content type could be specifically for events. Because of this, you most likely would like to display this content type in a calendar format. Luckily, Drupal's [Calendar](https://www.drupal.org/project/calendar) module does just that. However, if a user were to visit any of the term pages associated with that content type, they would simply get a list of content by default.

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/fin-1.png)

> The above image shows the default display for a term with a date field.

In this tutorial, I will show you how to update the term page display to display a calendar of nodes with that term, rather than a list.

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/fin-2.png)

> The above image shows the the same term display, this time in a calendar format.

Before we start, make sure you have the following configured:

1. Have a content type with a date field
2. This content type must also have a term reference field (preferably one not being used by other content types)
3. Install the m following modules.
   1. [Calendar](http://www.drupal.org/project/calendar)
   1. [Date](https://www.drupal.org/project/date)
   1. [Taxonomy Display](https://www.drupal.org/project/taxonomy_display)
   1. [Pathauto](https://www.drupal.org/project/pathauto)

In this tutorial my content type is called **Date** the date field is called **field_date** and my vocabulary is called **Date Category.**

## Update Taxonomy Term Path

Update your path for the term being used in the term reference field to the following:

    dates/[term:name]/month

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/2.1.png)

> If you have existing terms, you will need to delete their aliases and then bulk generate them.

## Create a New Calendar Display From Template

Navigate to **/admin/structure/views/add-template** and create a new calendar view from template. Make sure you add a calendar using your specific date field. In my case it's **field_date**.

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/3.1.png)

1. Name your view. I named mine **Calendar Term Display**

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/3.2.png)

2. On the month display, add a contextual filter for **Content: Has taxonomy term ID**

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/3.3.png)

3. Under **WHEN THE FILTER VALUE IS ** _NOT_ ** IN THE URL** , configure the following:

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/3.4.png)

4. **Provide default value** = enabled
5. **Type** = Taxonomy term ID from URL
6. **Load default filter from term page** = enabled
7. Click Apply (this display)
8. Rearrange the order of the contextual filters so that the **Content: Has taxonomy term ID** appears first​

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/3.6.png)

9. Under **PAGE SETTINGS** update the **path** to the **dates/%/month/%**. This is based off of the pattern we created earlier for the term being referenced. The first **%** represents the **term ID** and the second **%** represents the **start date.**

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/3.7.png)

10. Also under **PAGE SETTINGS** update the **Menu** to **No menu entry**

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/1.png)

11. Under **PAGER** update the **Link format** to **Pager** in the **settings** section.

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/2.png)

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/3.png)

12. Finally, under **OTHER** enable **AJAX**

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/4.png)

13. Save the view

## Update the Term Page Display

1. Navigate to your vocabulary's display settings at **admin/structure/taxonomy/your_vocabulary/display**
2. Enable **Taxonomy term page** and click Save

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/4.1.png)

3. Now click **Taxonomy term page** in the upper right hand corner

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/4.2.png)

4. Set **Term display** to **hidden**

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/4.3.png)

5. Set **Associated content display** to **Views**

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/4.4.png)

6. Set the **View** to the view we just created (in my case it's **Calendar Term Display** ), and set the **View's display** to **Month**

![](/assets/images/posts/display-calendar-taxonomy-pages-drupal/4.5.png)

7. Click **Save**
