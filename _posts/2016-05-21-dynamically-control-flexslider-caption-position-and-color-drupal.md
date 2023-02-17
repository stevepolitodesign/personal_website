---
title: Dynamically Control FlexSlider Caption Position and Color in Drupal
excerpt:
  Drupal’s Flex Slider module allows site builders to add rotating slides with
  captions. Using custom CSS, site themers can adjust the caption’s position and
  color. This is useful when the caption color might be hard to read against the
  slide, or is positioned awkwardly. However, wouldn’t it be nice to have complete
  control over the caption’s color, position and background color right within the
  CMS?
tags: ["Tutorial", "FlexSlider"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Flex Slider", url: "https://www.drupal.org/project/flexslider" },
    { title: "Color Field", url: "https://www.drupal.org/project/color_field" },
    { title: "Views", url: "https://www.drupal.org/project/views" },
  ]
date: 2016-05-21
node: 166
---

## Introduction and Requirements

Drupal's Flex Slider module allows site builders to add rotating slides with captions. Using custom CSS, site themers can adjust the caption's position and color. This is useful when the caption color might be hard to read against the slide, or is positioned awkwardly. However, wouldn't it be nice to have complete control over the caption's color, position and background color right within the CMS?

![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/flex-caption.gif)

> The above image shows a FlexSlider that is using inline styles that a content editor has complete control over.

![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/intro-1.png)

> The above image shows the edit page for a slide. The content editor has complete control over the caption's color, background color and position.

This tutorial assumes you're able to edit your theme's custom JavaScript file(s). I am using [Zen](https://www.drupal.org/project/zen), but you are able to add custom scripts to any Drupal theme. You will also need the following modules and their dependencies and/or libraries installed.

- [Flex Slider](https://www.drupal.org/project/flexslider)
  - FlexSlider Views Style Sub Module
- [Color Field](https://www.drupal.org/project/color_field)
- [Views](https://www.drupal.org/project/views)

## Create a Content Type for Your Slides

1. Create a new **content type** by navigating to **/admin/structure/types/add**. In this tutorial, I will call it **Slides**

   ![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/1.1_1.png)

2. Add the following fields to your content type.

| **Label**        | **Field Type** | **Widget**                | **Required** |
| ---------------- | -------------- | ------------------------- | ------------ |
| Slide            | Image          | Image                     | Yes          |
| Caption          | Long Text      | Text area (multiple rows) | Yes          |
| Caption Color    | Color Field    | Pre-selected color boxes  | Yes          |
| Caption BG Color | Color Field    | Pre-selected color boxes  | Yes          |
| Top              | Text           | Text field                | Yes          |
| Right            | Text           | Text field                | Yes          |
| Bottom           | Text           | Text field                | Yes          |
| Left             | Text           | Text field                | Yes          |

![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/1.2_0.png)

> I recommend adding help text to the **Top** , **Right** , **Bottom** and **Left** fields. Not all content editors will be familiar with CSS

    Allowed values: auto|length|initial|inherit<br>
    <em>length</em> can be a positive or negative number, and should end with "px", "em", or "%"

![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/1.3_0.png)

## Create a FlexSlider View

1. Create a new view by navigating to the following URL **/admin/structure/views/add**
1. Configure the view as follows:

   1. Show **content** of **Slides** sorted by **newest first**
   2. Create a **block** and set the **Display format** to **FlexSlider** of **fields**
   3. Empty the I **tems per page** field, and disable **Use a pager**

      ![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/2.1_0.png)

1. Add all the fields (except the title field) from your **Slides** content type.

   ![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/2.2.png)

1. With the exception of the **Slide** field, enable **Exclude from display** on all the fields you added.

   ![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/2.3.png)

1. For the **Caption Color** and **Caption BG Color** fields, make sure the **Formatter** is set to **Plain text color**

   ![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/2.5.png)

1. Re-arrange the fields so that the **Caption** field is last.

   ![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/2.4.png)

1. Edit the **Caption** field and enable **Rewrite the output of this field** and enter the following code

   ![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/2.6.png)

   ```html
   <div
     class="caption-wrapper"
     data-color="[field_caption_color]"
     data-bg-color="[field_caption_bg_color]"
     data-top="[field_top]"
     data-right="[field_right]"
     data-bottom="[field_bottom]"
     data-left="[field_left]"
   >
     [field_caption]
   </div>
   ```

1. Under the **Settings** for the FlexSlider format, set the **Caption Field** to **Content: Caption**

   ![](/assets/images/posts/dynamically-control-flexslider-caption-position-and-color-drupal/2.7.png)

1. Save the view.

## Add a Custom Script to Style the FlexSlider Caption

Open your theme's custom script file, and add the following code.

```javascript
$(document).ready(function () {
  /* cycle through each caption, and set its data attributes as varibales */
  $(".caption-wrapper").each(function () {
    var topPos = $(this).attr("data-top");
    var rightPos = $(this).attr("data-right");
    var bottomPos = $(this).attr("data-bottom");
    var leftPos = $(this).attr("data-left");
    var capColor = $(this).attr("data-color");
    var capBGColor = $(this).attr("data-bg-color");

    /* use the variables as inline styles */
    $(this).css({
      top: topPos,
      right: rightPos,
      bottom: bottomPos,
      left: leftPos,
      color: capColor,
      "background-color": capBGColor,
      position:
        "absolute" /* this ensures that the caption is positioned over the slide */,
      "z-index":
        "1" /* this ensures that the caption is positioned over the slide */,
    });
  });
});
```

## Conclusion and Next Steps

Moving forward, you could add additional fields to your **Slides** content type that correspond to a CSS property. This concept doesn't have to be limited to FlexSlider either. You could do the same thing with unformatted lists views, where you want to gave greater control of their display.
