---
title: Correctly Display Repeating Dates In Drupal
tags: ["Tutorial", "Date"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Date", url: "https://www.drupal.org/project/date" },
    { title: "Views", url: "https://www.drupal.org/project/views" },
  ]
date: 2016-02-16
node: 158
---

## Configure Site Date and Time

1. Navigate to **admin/config/regional/date-time**

![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-16-at-6.48.25-AM.png)

## Enable The Necessary Modules

- Date
- Date All Day
- Date API
- Date Popup
- Date Repeat API
- Date Repeat Field
- Date Tools
- Date Views

## Configure A Repeating Date Field

Make sure you have at least one date field configured to handle repeating dates.

Under **MORE SETTINGS AND VALUES \> DATE ENTRY** configure the following:

- Set **Date entry options** to a format that is easy to read. For example, something that has **AM** and **PM**
- Enable **Display all day checkbox**

![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-16-at-6.57.42-AM.png)

Under the **FIELD SETTINGS** configure the following:

- Under **Date attributes to collect** enable the following
  - Year, Month, Day, Hour and Minute
- Enable **Collect an end date**
- Under **Repeating date** select **Yes**

![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-16-at-6.52.03-AM.png)

## Make Sure You're Entering Your Dates Correctly

It's easy to enter the dates incorrectly, which in turn makes repeating dates display incorrectly.

> Make sure your **End Date** reflects the the **time** your event ends. So, if you have a repeating date that starts at 12:00pm and ends at 12:30pm, make sure this is reflected in the end date. The date itself should be the same

![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-17-at-7.36.29-AM.png)

> Use the **Repeat** rule to actually add the date the event ends.

![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-16-at-7.02.42-AM.png)

## Correctly Display Repeating Dates In Views

You'll notice that if you create a view that displays repeating dates, the view can become overwhelming quickly as demonstrated below.

> For example, if the event repeats 11 times, the view will display 11 instances of the event while still displaying all repeating dates that have occurred.

![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-17-at-7.36.58-AM.png)

### Limit View To Only Show Upcoming Repeating Dates

The first thing we'll want to do is limit the view to only show upcoming repeating events, and not ones that have already occurred. For example, I'm writing this on February 17<sup>th</sup>, 2016 and my repeating event started on February 3<sup>rd</sup>, 2016. In the image above, there are 11 instances of the event (one for each repeating date). However, since 3 instance of this event are over, the view should only display 8 instances.

> In order to limit a view to only show upcoming repeating events, make sure you're displaying your data as fields, and not as content such as teasers.

1. Under **FILTER CRITERIA** search for **Date: Date (node)** (note this this is different than the date field in your node)

   ![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-17-at-7.44.02-AM.png)

2. For **Date selection form element, Filter granularity** and ** Starting year** you can use the default settings

   ![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-17-at-7.44.47-AM.png)

3. Under **Date field(s)** find the date field you are using in your nodes, and specifically **select the start date value**

   ![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-17-at-7.45.56-AM.png)

4. For **Method** select **OR**

   ![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-17-at-7.47.18-AM.png)

5. On the next page, select **Is greater than or equal to** for the **Operator**
6. **Enter a relative date** and use **12AM today** as the relative date

   ![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-17-at-7.47.51-AM.png)

### Display Each Repeating Date In Its Own Row

Even though we've limited our view to only show upcoming repeating dates, it's still very cluttered. Each row of a repeating date still shows all instances of that repeating date. What we want to do is show each instance in its own row.

> The image on the left is what we currently have configured. The image on the right is what we're looking to achieve.

![](/assets/images/posts/correctly-display-repeating-dates-drupal/date.jpg)

1. Edit your date field in the view we created in the previous steps. Under **MULTIPLE FIELD SETTINGS** deselect **Display all values in the same row**

![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-18-at-6.11.56-AM.png)

## Correctly Display Repeating Dates Using Relative Start Date

By default, a repeating date will display all instances on the node display as demonstrated below. This creates a cluttered display, and is also not helpful once an instance is over.

![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-17-at-7.36.48-AM.png)

Luckily [there is a patch](https://www.drupal.org/files/date-allow-relative-dates-for-output-filter.patch) that supports relative date formats in the filter of the date field output formatter.

1. Using the command line, navigate to the **date** module directory.

   ```sh
   cd sites/all/modules/date
   ```

2. Apply the patch. I am on a Mac, so I use the following code when applying patches.

   ```sh
   wget https://www.drupal.org/files/date-allow-relative-dates-for-output-filter.patchpatch -p1 < date-allow-relative-dates-for-output-filter.patchrm date-allow-relative-dates-for-output-filter.patch
   ```

3. Navigate to the default display for your content type that has a date field. 4. Under **starting from** enter **now** 5. Select **Use php relative dates notation**

   ![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-19-at-1.34.35-PM.png)

4. Click **Update** then **Save**

I'm writing this section on February 18<sup>th</sup>, 2016. So, my event that repeats from February 3<sup>rd</sup>, 2016 - April 19<sup>th</sup>, 2016 will now only show instances that have yet to occur.

![](/assets/images/posts/correctly-display-repeating-dates-drupal/Screen-Shot-2016-02-19-at-1.35.05-PM.png)
