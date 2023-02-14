---
title: WordPress ACF Frontend Form Tutorial (With Email Notifications)
resources:
  [
    {
      title: "ACF Frontend Form Documentation",
      url: "https://www.advancedcustomfields.com/resources/create-a-front-end-form/",
    },
    {
      title: "acf_register_form()",
      url: "https://www.advancedcustomfields.com/resources/acf_register_form/",
    },
    {
      title: "acf/save_post",
      url: "https://www.advancedcustomfields.com/resources/acf-save_post/",
    },
  ]
categories: ["WordPress"]
tags: ["ACF"]
date: 2019-03-31
---

In this tutorial I'm going to show you how to create a frontend form for a custom post type that anonymous users can fill out. As an added bonus I'll show you how you can trigger an email to be sent each time the form is submitted.

> Below is what the anonymous user will fill out.

![acf frontend form](/assets/images/posts/wordpress-acf-front-end-form-tutorial/demo.gif)

> Below is the email an administrator will receive once a new recipe is posted to the site.

![the email an administrator will receive once a new recipe is posted to the site](/assets/images/posts/wordpress-acf-front-end-form-tutorial/demo-email.png)

> Below is the submitted recipe which will automatically be saved as a draft for review. The administrator will be able to flag these recipes as featured, and will chose to publish them.

![admin view of recently added recipe](/assets/images/posts/wordpress-acf-front-end-form-tutorial/demo-admin-view.gif)

## 0. Setup

For this tutorial we are going to build a form that allows users to post recipes to our site. The form will allow for the following fields to be filled in by an anonymous user.

1. Title
1. Description
1. Image (custom field)
1. Ingredients (custom field)
1. Directions (custom field)
1. Category (custom taxonomy)

There will also be a custom field that allows admins to select if the recipe should be featured or not. However, this field will not be visible on the frontend form.

<a name="recipe-custom-post-type"></a>

### Recipe Custom Post Type

1. Create a `mu-plugins` directory in `wp-content` by running `mkdir wp-content/mu-plugins` in the root of you WordPress install
1. Create a `custom-post-types.php` file in the `mu-plugins` directory by running `touch wp-content/mu-plugins/custom-post-types.php`
1. Paste the following into the `custom-post-types.php` file.

```php
<?php
/**
 * Registers the `recipe` post type.
 */
function recipe_init()
{
  register_post_type("recipe", [
    "labels" => [
      "name" => __("Recipes", "YOUR-TEXTDOMAIN"),
      "singular_name" => __("Recipe", "YOUR-TEXTDOMAIN"),
      "all_items" => __("All Recipes", "YOUR-TEXTDOMAIN"),
      "archives" => __("Recipe Archives", "YOUR-TEXTDOMAIN"),
      "attributes" => __("Recipe Attributes", "YOUR-TEXTDOMAIN"),
      "insert_into_item" => __("Insert into recipe", "YOUR-TEXTDOMAIN"),
      "uploaded_to_this_item" => __(
        "Uploaded to this recipe",
        "YOUR-TEXTDOMAIN"
      ),
      "featured_image" => _x("Featured Image", "recipe", "YOUR-TEXTDOMAIN"),
      "set_featured_image" => _x(
        "Set featured image",
        "recipe",
        "YOUR-TEXTDOMAIN"
      ),
      "remove_featured_image" => _x(
        "Remove featured image",
        "recipe",
        "YOUR-TEXTDOMAIN"
      ),
      "use_featured_image" => _x(
        "Use as featured image",
        "recipe",
        "YOUR-TEXTDOMAIN"
      ),
      "filter_items_list" => __("Filter recipes list", "YOUR-TEXTDOMAIN"),
      "items_list_navigation" => __(
        "Recipes list navigation",
        "YOUR-TEXTDOMAIN"
      ),
      "items_list" => __("Recipes list", "YOUR-TEXTDOMAIN"),
      "new_item" => __("New Recipe", "YOUR-TEXTDOMAIN"),
      "add_new" => __("Add New", "YOUR-TEXTDOMAIN"),
      "add_new_item" => __("Add New Recipe", "YOUR-TEXTDOMAIN"),
      "edit_item" => __("Edit Recipe", "YOUR-TEXTDOMAIN"),
      "view_item" => __("View Recipe", "YOUR-TEXTDOMAIN"),
      "view_items" => __("View Recipes", "YOUR-TEXTDOMAIN"),
      "search_items" => __("Search recipes", "YOUR-TEXTDOMAIN"),
      "not_found" => __("No recipes found", "YOUR-TEXTDOMAIN"),
      "not_found_in_trash" => __(
        "No recipes found in trash",
        "YOUR-TEXTDOMAIN"
      ),
      "parent_item_colon" => __("Parent Recipe:", "YOUR-TEXTDOMAIN"),
      "menu_name" => __("Recipes", "YOUR-TEXTDOMAIN"),
    ],
    "public" => true,
    "hierarchical" => false,
    "show_ui" => true,
    "show_in_nav_menus" => true,
    "supports" => ["title", "editor"],
    "has_archive" => true,
    "rewrite" => true,
    "query_var" => true,
    "menu_position" => null,
    "menu_icon" => "dashicons-admin-post",
    "show_in_rest" => true,
    "rest_base" => "recipe",
    "rest_controller_class" => "WP_REST_Posts_Controller",
  ]);
}
add_action("init", "recipe_init");

/**
 * Sets the post updated messages for the `recipe` post type.
 *
 * @param  array $messages Post updated messages.
 * @return array Messages for the `recipe` post type.
 */
function recipe_updated_messages($messages)
{
  global $post;

  $permalink = get_permalink($post);

  $messages["recipe"] = [
    0 => "", // Unused. Messages start at index 1.
    /* translators: %s: post permalink */
    1 => sprintf(
      __(
        'Recipe updated. <a target="_blank" href="%s">View recipe</a>',
        "YOUR-TEXTDOMAIN"
      ),
      esc_url($permalink)
    ),
    2 => __("Custom field updated.", "YOUR-TEXTDOMAIN"),
    3 => __("Custom field deleted.", "YOUR-TEXTDOMAIN"),
    4 => __("Recipe updated.", "YOUR-TEXTDOMAIN"),
    /* translators: %s: date and time of the revision */
    5 => isset($_GET["revision"])
      ? sprintf(
        __("Recipe restored to revision from %s", "YOUR-TEXTDOMAIN"),
        wp_post_revision_title((int) $_GET["revision"], false)
      )
      : false,
    /* translators: %s: post permalink */
    6 => sprintf(
      __('Recipe published. <a href="%s">View recipe</a>', "YOUR-TEXTDOMAIN"),
      esc_url($permalink)
    ),
    7 => __("Recipe saved.", "YOUR-TEXTDOMAIN"),
    /* translators: %s: post permalink */
    8 => sprintf(
      __(
        'Recipe submitted. <a target="_blank" href="%s">Preview recipe</a>',
        "YOUR-TEXTDOMAIN"
      ),
      esc_url(add_query_arg("preview", "true", $permalink))
    ),
    /* translators: 1: Publish box date format, see https://secure.php.net/date 2: Post permalink */
    9 => sprintf(
      __(
        'Recipe scheduled for: <strong>%1$s</strong>. <a target="_blank" href="%2$s">Preview recipe</a>',
        "YOUR-TEXTDOMAIN"
      ),
      date_i18n(
        __("M j, Y @ G:i", "YOUR-TEXTDOMAIN"),
        strtotime($post->post_date)
      ),
      esc_url($permalink)
    ),
    /* translators: %s: post permalink */
    10 => sprintf(
      __(
        'Recipe draft updated. <a target="_blank" href="%s">Preview recipe</a>',
        "YOUR-TEXTDOMAIN"
      ),
      esc_url(add_query_arg("preview", "true", $permalink))
    ),
  ];

  return $messages;
}
add_filter("post_updated_messages", "recipe_updated_messages");
```

<a name="recipe-custom-taxonomy"></a>

### Recipe Category Custom Taxonomy

1. Create a `custom-taxonomies.php` file in the `mu-plugins` directory by running `touch wp-content/mu-plugins/custom-taxonomies.php`
1. Paste the following into the `custom-taxonomies.php` file.

```php
<?php

/**
 * Registers the `recipe_category` taxonomy,
 * for use with 'recipe'.
 */
function recipe_category_init()
{
  register_taxonomy(
    "recipe_category",
    ["recipe"],
    [
      "hierarchical" => false,
      "public" => true,
      "show_in_nav_menus" => true,
      "show_ui" => true,
      "show_admin_column" => false,
      "query_var" => true,
      "rewrite" => true,
      "capabilities" => [
        "manage_terms" => "edit_posts",
        "edit_terms" => "edit_posts",
        "delete_terms" => "edit_posts",
        "assign_terms" => "edit_posts",
      ],
      "labels" => [
        "name" => __("Recipe categories", "YOUR-TEXTDOMAIN"),
        "singular_name" => _x(
          "Recipe category",
          "taxonomy general name",
          "YOUR-TEXTDOMAIN"
        ),
        "search_items" => __("Search Recipe categories", "YOUR-TEXTDOMAIN"),
        "popular_items" => __("Popular Recipe categories", "YOUR-TEXTDOMAIN"),
        "all_items" => __("All Recipe categories", "YOUR-TEXTDOMAIN"),
        "parent_item" => __("Parent Recipe category", "YOUR-TEXTDOMAIN"),
        "parent_item_colon" => __("Parent Recipe category:", "YOUR-TEXTDOMAIN"),
        "edit_item" => __("Edit Recipe category", "YOUR-TEXTDOMAIN"),
        "update_item" => __("Update Recipe category", "YOUR-TEXTDOMAIN"),
        "view_item" => __("View Recipe category", "YOUR-TEXTDOMAIN"),
        "add_new_item" => __("Add New Recipe category", "YOUR-TEXTDOMAIN"),
        "new_item_name" => __("New Recipe category", "YOUR-TEXTDOMAIN"),
        "separate_items_with_commas" => __(
          "Separate recipe categories with commas",
          "YOUR-TEXTDOMAIN"
        ),
        "add_or_remove_items" => __(
          "Add or remove recipe categories",
          "YOUR-TEXTDOMAIN"
        ),
        "choose_from_most_used" => __(
          "Choose from the most used recipe categories",
          "YOUR-TEXTDOMAIN"
        ),
        "not_found" => __("No recipe categories found.", "YOUR-TEXTDOMAIN"),
        "no_terms" => __("No recipe categories", "YOUR-TEXTDOMAIN"),
        "menu_name" => __("Recipe categories", "YOUR-TEXTDOMAIN"),
        "items_list_navigation" => __(
          "Recipe categories list navigation",
          "YOUR-TEXTDOMAIN"
        ),
        "items_list" => __("Recipe categories list", "YOUR-TEXTDOMAIN"),
        "most_used" => _x("Most Used", "recipe_category", "YOUR-TEXTDOMAIN"),
        "back_to_items" => __(
          "&larr; Back to Recipe categories",
          "YOUR-TEXTDOMAIN"
        ),
      ],
      "show_in_rest" => true,
      "rest_base" => "recipe_category",
      "rest_controller_class" => "WP_REST_Terms_Controller",
    ]
  );
}
add_action("init", "recipe_category_init");

/**
 * Sets the post updated messages for the `recipe_category` taxonomy.
 *
 * @param  array $messages Post updated messages.
 * @return array Messages for the `recipe_category` taxonomy.
 */
function recipe_category_updated_messages($messages)
{
  $messages["recipe_category"] = [
    0 => "", // Unused. Messages start at index 1.
    1 => __("Recipe category added.", "YOUR-TEXTDOMAIN"),
    2 => __("Recipe category deleted.", "YOUR-TEXTDOMAIN"),
    3 => __("Recipe category updated.", "YOUR-TEXTDOMAIN"),
    4 => __("Recipe category not added.", "YOUR-TEXTDOMAIN"),
    5 => __("Recipe category not updated.", "YOUR-TEXTDOMAIN"),
    6 => __("Recipe categories deleted.", "YOUR-TEXTDOMAIN"),
  ];

  return $messages;
}
add_filter("term_updated_messages", "recipe_category_updated_messages");
```

Below is how the directory structure should look.

![custom post types and custom taxonomies](/assets/images/posts/wordpress-acf-front-end-form-tutorial/0.2.png)

### Recipe Custom Fields

1. Install the activate the [Advanced Custom Fields](https://wordpress.org/plugins/advanced-custom-fields/) plugin
1. Import the <a href="/assets/acf-export.json" download>ACF Recipe Fields</a>. The field group should look like this:

![custom fields for recipe post type](/assets/images/posts/wordpress-acf-front-end-form-tutorial/0.1.png)

> Note that Create Terms, Save Terms and Load Terms is enabled for the Category Field

## 1. Create a Custom Page Template for the Frontend Form

Now that we have completed the initial setup, we need to create a page for the frontend form.

1. Duplicate the `page.php` template file in your theme, and rename it to something obvious. I chose to rename it `custom-template-recipe-front-end-form.php`.
1. Make sure to add `Template Name: Recipe Frontend Form` to the top of the file.

```php
<?php
/**
 * Template Name: Recipe Frontend Form
 *
 * @link
   https://developer.wordpress.org/themes/basics/template-hierarchy/#single-post
 *
 * @package WordPress
 * @subpackage Twenty_Nineteen
 * @since 1.0.0
 */

get_header();
?>
```

## 2. Add the Frontend Form to the Custom Page Template

Now that we have a page template to load the form, we need to build the form.

1. Add `acf_form_head();` to the template you just created.

   > [This function](https://www.advancedcustomfields.com/resources/acf_form_head/) is placed at the top of a template file and will register the necessary assets (CSS/JS), process the saved data, and redirect the url. This function does not accept any parameters

   ```php
   <?php
   /**
    * Template Name: Recipe Frontend Form
    *
    * @link https://developer.wordpress.org/themes/basics/template-hierarchy/#single-post
    *
    * @package WordPress
    * @subpackage Twenty_Nineteen
    * @since 1.0.0
    */

   acf_form_head();
   get_header();

   ?>
   ```

1. Create a whitelist of fields you wish the form to display. This step is necessary for our form because we don't want anonymous users to have access to the **Featured** field. This field is only intended for admins.

   - Navigate to the **Recipe Field Group** and take note of the field keys. If you don't see the field keys, make sure they're enabled under **Screen Options**

   ![enable field keys under screen options](/assets/images/posts/wordpress-acf-front-end-form-tutorial/2.1.gif)

   - Store the field keys in an array. Make sure not to store the field key for the **Featured** field, since we don't want anonymous users to have access to that field.

   ```php
   <?php
   /**
    * Template Name: Recipe Frontend Form
    *
    * @link https://developer.wordpress.org/themes/basics/template-hierarchy/#single-post
    *
    * @package WordPress
    * @subpackage Twenty_Nineteen
    * @since 1.0.0
    */

   acf_form_head();
   get_header();
   ?>
   
       <section id="primary" class="content-area">
       <main id="main" class="site-main">
   
       /* Start the Loop */<?php while (have_posts()):
         the_post();

         get_template_part("template-parts/content/content", "page");

         // If comments are open or we have at least one comment, load up the comment template.
         if (comments_open() || get_comments_number()) {
           comments_template();
         }
       endwhile;
   // End of the loop.
   ?>
   
       <?php $fields = [
         "field_5c9ca61a3a561", // image
         "field_5c9ca6543a562", // ingredients
         "field_5c9ca6723a563", // directions
         "field_5c9ca67d3a564", // category
       ]; ?>
   
       </main><!-- #main -->
       </section><!-- #primary -->
   
   <?php get_footer();
   ```

1. Register the frontend form using the [acf_register_form()](https://www.advancedcustomfields.com/resources/acf_register_form/) function.

   ```php
   <?php
   /**
    * Template Name: Recipe Frontend Form
    *
    * @link https://developer.wordpress.org/themes/basics/template-hierarchy/#single-post
    *
    * @package WordPress
    * @subpackage Twenty_Nineteen
    * @since 1.0.0
    */

   acf_form_head();
   get_header();
   ?>
   
       <section id="primary" class="content-area">
       <main id="main" class="site-main">
   
       /* Start the Loop */<?php while (have_posts()):
         the_post();

         get_template_part("template-parts/content/content", "page");

         // If comments are open or we have at least one comment, load up the comment template.
         if (comments_open() || get_comments_number()) {
           comments_template();
         }
       endwhile;
   // End of the loop.
   ?>
   
       <?php
       $fields = [
         "field_5c9ca61a3a561", // image
         "field_5c9ca6543a562", // ingredients
         "field_5c9ca6723a563", // directions
         "field_5c9ca67d3a564", // category
       ];
       acf_register_form([
         "id" => "new-recipe",
         "post_id" => "new_post",
         "new_post" => [
           "post_type" => "recipe",
           "post_status" => "draft",
         ],
         "post_title" => true,
         "post_content" => true,
         "uploader" => "basic",
         "return" => home_url("thank-your-for-submitting-your-recipe"),
         "fields" => $fields,
         "submit_value" => "Submit a new Recipe",
       ]);

       // Load the form
       acf_form("new-recipe");
       ?>
   
         </main><!-- #main -->
       </section><!-- #primary -->
   
   <?php get_footer();
   ```

   > There are many settings available to customize a form and these are set by adding to the $settings array as explained below.

   | Argument     | Description                                                                                                                                                                                            |
   | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
   | id           | This is the unique identifier for the form. We'll use this as the only argument when we call `acf_form()`                                                                                              |
   | post_id      | This is set to `new_post` because we're creating a new post. If we we're editing a post, then we would set this value to the post ID                                                                   |
   | new_post     | We set the `post_type` to `recipe` because that's the name of the post type we're creating. We set `post_status` to `draft` because we want admins to preview each recipes before posting to the site. |
   | post_title   | We set this to `true` so that the default post title is available in the form                                                                                                                          |
   | post_content | We set this to `true` so that the default post description is available in the form                                                                                                                    |
   | uploader     | Whether to use the WP uploader or a basic input for image and file fields. We set this to `basic` because an anonymous user shouldn't have access to the WordPress media library.                      |
   | return       | The URL to be redirected to after the form is submitted.                                                                                                                                               |
   | submit_value | The text displayed on the submit button.                                                                                                                                                               |

1. Add a new page to your site, making sure to set the **template** to **Recipe Frontend Form**. You should see something similar to the following.

![acf frontend form](/assets/images/posts/wordpress-acf-front-end-form-tutorial/2.2.png)

<a name="alert-admins-when-a-new-recipe-has-been-submitted"></a>

## 3. Alert Admins When a New Recipe Has Been Submitted (Optional)

Now that we have a working form that allows anonymous users to post from the frontend, we should alert admins of each new submission.

1. Create a `custom-mailers.php` file in the `mu-plugins` directory by running `touch wp-content/mu-plugins/custom-mailers.php`
1. Paste the following into the file.

```php
<?php
add_action("acf/save_post", "YOUR_THEME_NAME_new_recipe_send_email");

function YOUR_THEME_NAME_new_recipe_send_email($post_id)
{
  if (
    get_post_type($post_id) !== "recipe" &&
    get_post_status($post_id) == "draft"
  ) {
    return;
  }

  if (is_admin()) {
    return;
  }

  $post_title = get_the_title($post_id);
  $post_url = get_permalink($post_id);
  $subject = "A New Recipe Has Been Added to Your Site";
  $message = "Please Review the recipe before publishing:\n\n";
  $message .= $post_title . ": " . $post_url;

  $administrators = get_users([
    "role" => "administrator",
  ]);

  foreach ($administrators as &$administrator) {
    wp_mail($administrator->data->user_email, $subject, $message);
  }
}
```

- We use the [acf/save_post](https://www.advancedcustomfields.com/resources/acf-save_post/) hook to call this function each time a new post is submitted.
- To make sure this function is only called when a recipe is added from the frontend form, and not the admin dashboard, we use the following conditional.

```php
if (
  get_post_type($post_id) !== "recipe" &&
  get_post_status($post_id) == "draft"
) {
  return;
}

if (is_admin()) {
  return;
}
```

- We then build out a custom message and subject for the email. It's helpful to have the post title and link to the post in the body, but your message can be different.

```php
$post_title = get_the_title($post_id);
$post_url = get_permalink($post_id);
$subject = "A New Recipe Has Been Added to Your Site";
$message = "Please Review the recipe before publishing:\n\n";
$message .= $post_title . ": " . $post_url;
```

- Then we gather a list of `administrators` on the site so each can be emailed. However, you could select a different role, or chose to add a custom email address.

```php
$administrators = get_users([
  "role" => "administrator",
]);
```

- Finally, we loop through the list of `administrators` and send an email to each using our custom subject and body.

```php
foreach ($administrators as &$administrator) {
  wp_mail($administrator->data->user_email, $subject, $message);
}
```
