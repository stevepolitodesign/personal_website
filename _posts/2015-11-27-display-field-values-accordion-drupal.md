---
title: Display Field Values in an Accordion In Drupal
tags: ["UI", "Tutorial"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Field Group", url: "https://www.drupal.org/project/field_group" },
    {
      title: "Field collection",
      url: "https://www.drupal.org/project/field_collection",
    },
  ]
date: 2015-11-27
---

You probably already know that Drupal offers [Views Accordion](https://www.drupal.org/project/views_accordion) to display content in [jQuery Accordions](https://jqueryui.com/accordion/). This is fine if you're looking to display specific content in this format, like a custom content type. However, what if you're simply looking to display field values from a node on the node's display in an accordion? This would require the use of contextual filters and block views if you were to use [Views Accordion](https://www.drupal.org/project/views_accordion). However, there's a much simpler way to achieve this functionality with [Field Group](https://www.drupal.org/project/field_group) and [Field collection](https://www.drupal.org/project/field_collection).

**Below is the final result:**

![](/assets/images/posts/display-field-values-accordion-drupal/accordion-1.gif)

> The above image shows how the field data is displayed on a node in an accordion format.

![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-28-at-9.41.02-AM.png)

> The above image shows how the field data is stored in the node. Users have complete control over the accordion title and body.

## Install and Enable The Necessary Modules

Install and enable [Field Group](https://www.drupal.org/project/field_group) and [Field collection](https://www.drupal.org/project/field_collection) and their dependencies.

![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-10.56.16-AM.png)

## Create a Field Collection Field

Navigate to an existing content type and add a new field using the **Field collection** Field Type. In my case I am going to use the default **Basic Page** content type. You can also create a new custom content type if you wish.

1. Add a new field called **Accordion** and set the field type to **Field collection**

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-10.57.13-AM.png)

2. Under Field Settings select **Hide blank items** and set **Number of Values** to **Unlimited**

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-10.59.09-AM.png)

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-10.59.52-AM.png)

3. Under the **Manage Display Tab**, located at **admin/structure/types/manage/your-content-type/display** configure the following:

   1. Set the **Label** to **<Hidden\>**
   2. Set the **Format** to **Field only**
   3. Set the **View mode:** to **Full content**

      ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-11.03.40-AM.png)

4. Save

## Configure the Field Collection Field To Display Content In An Accordion

1. Navigate to the field collection configuration page at **admin/structure/field-collections** and select **manage fields** for the field collection we just created

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-11.05.47-AM.png)

2. Add a **Text** field with the following configuration:

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-11.06.38-AM.png)

3. Enable **Required field**

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-11.08.01-AM.png)

4. Set **Number of values** to 1

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-11.08.07-AM.png)

5. Add a **Long text** field with the following configuration:

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-27-at-11.09.42-AM.png)

6. Set **Text processing** to **Filtered text**

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-28-at-9.31.37-AM.png)

7. Enable **Required field**

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-28-at-9.32.05-AM.png)

8. Set **Number of values** to 1

   ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-28-at-9.32.26-AM.png)

9. Navigate to the **Mange Display** tab for the field collection at **admin/structure/field-collections/field-accordion/display**
10. Add a new **field group** with the following configuration
11. Label: **Accordion Wrapper**
12. Group Name: **group_accordion_wrapper**
13. Format: **Accordion Group**

    ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-28-at-9.34.39-AM.png)

14. Save
15. Nest the **Accordion Title** and **Accordion Body** fields under the **Accordion Wrapper** group you just created.
16. Use the default settings for **Accordion Wrapper**
17. Set the labels for **Accordion Title** and **Accordion Body** to **<Hidden\>**

    ![](/assets/images/posts/display-field-values-accordion-drupal/Screen-Shot-2015-11-28-at-9.36.34-AM.png)

18. Save

## Conclusion and Next Steps

Now you can navigate to your content type that has the field collection and start adding custom accordion elements. This is different than [Views Accordion](https://www.drupal.org/project/views_accordion) because the accordion formatting happens directly on the node, rather than in a custom view that need to be configured.
