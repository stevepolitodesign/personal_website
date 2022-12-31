---
title: Add a Featured Image to the Events Calendar Month, List and Day Views in WordPress
categories: ["WordPress"]
resources: [
    {
        title: "ACF Options Page",
        url: "https://www.advancedcustomfields.com/resources/options-page/#basic-usage"
    },
    {
        title: "ACF Options Page: Template Usage",
        url: "https://www.advancedcustomfields.com/resources/options-page/#template-usage"
    },
    {
        title: "The Events Calendar Conditional Wrappers",
        url: "https://gist.github.com/jo-snips/2415009"
    },
    {
      title: "The Events Calendar Developer Documentation",
      url: "https://docs.theeventscalendar.com/"  
    }
]
date: 2019-10-28
---

By default, WordPress allows you to assign a featured image to a page or post. However, if you're using [The Events Calendar](https://wordpress.org/plugins/the-events-calendar/), you'll notice there's no easy way to assign a featured image to the events month, list or day views.

Fortunately, [ACF Pro](https://www.advancedcustomfields.com/pro/) allows us to create an [options](https://www.advancedcustomfields.com/resources/options-page/#basic-usage) page which can have fields assigned to it. We can then use these fields to conditionally render an image to the events month, list and day views.

{% youtube "https://www.youtube.com/embed/7ZQsjiGReXA" %}

## Step 1. Create an Options Page

Add a [basic option page](https://www.advancedcustomfields.com/resources/options-page/#basic-usage) per the documentation.

```php
// functions.php
if( function_exists('acf_add_options_page') ) {

	acf_add_options_page();

}
```

## Step 2. Assign an Image Field to the Options Page

Create a new field group, and assign it to the newly created options page.

![ACF Settings for a field assigned to a the options page](/assets/images/posts/add-featured-image-to-events-calendar-month-list-and-day-views-in-wordpress/acf-option-page-field-settings.png)

## Step 3. Conditionally Render the Image on the Events Month, List and Day View

Using [events calendar conditional wrappers](https://gist.github.com/jo-snips/2415009) in combination with the [ACF options page template usage](https://www.advancedcustomfields.com/resources/options-page/#template-usage), we can display the image on the events month, list and day views.

```php
<?php if( tribe_is_month() || tribe_is_past() || tribe_is_upcoming() || tribe_is_day() ) { ?>
  <?php
    $image = get_field('event_banner_image', 'option');
  ?>
  <img src="<?php echo esc_url($image['sizes']['large']); ?>" alt="<?php echo esc_attr($image['alt']); ?>">
<?php } ?>
```
