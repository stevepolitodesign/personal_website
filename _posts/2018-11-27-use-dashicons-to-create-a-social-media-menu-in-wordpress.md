---
title: Use Dashicons to Create a Social Media Menu in WordPress
tags: ["Theming"]
categories: ["WordPress"]
resources: [{
    title: "Dashicons",
    url: "https://developer.wordpress.org/resource/dashicons/"
},{
  title: "Register a new menu",
  url: "https://developer.wordpress.org/reference/functions/register_nav_menu/"
},
{
  title: "The CSS class screen-reader-text",
  url: "https://make.wordpress.org/accessibility/handbook/markup/the-css-class-screen-reader-text/"
}
]
date: 2018-11-27
---

> There are plenty of plugins that allow you to add social media icons to your WordPress site. **However, I always advocate avoiding plugins in favor of rolling out your own solution**. Don't fall into the trap of installing a plugin when you can develop your own solution using the WordPress API.

In this tutorial we are going to use [Dashicons](https://developer.wordpress.org/resource/dashicons/) to create a custom social media menu.

For this tutorial, I created a child theme of **twentyseventeen** and named the theme **example-theme**. However, the steps below can easily be applied to your custom of templated theme. Below is the final result.

![social media menu using dashicons](/assets/images/posts/use-dashicons-to-create-a-social-media-menu-in-wordpress/social-media-menu.png)

## 1. Load Dashicons on the Front End

1. Add `wp_enqueue_style( 'dashicons' );` to your theme's `functions.php` file.

```php{12-13}
add_action( 'wp_enqueue_scripts', 'twentyseventeen_parent_theme_enqueue_styles' );

/**
 * Enqueue scripts and styles.
 */
function twentyseventeen_parent_theme_enqueue_styles() {
	wp_enqueue_style( 'twentyseventeen-style', get_template_directory_uri() . '/style.css' );
	wp_enqueue_style( 'example-theme-style',
		get_stylesheet_directory_uri() . '/style.css',
		array( 'twentyseventeen-style' )
	);
	// load dashicons to the front end
	wp_enqueue_style( 'dashicons' );
}
```

## 2. Add a New Social Media Menu to Your Theme

1. [Register a new menu](https://developer.wordpress.org/reference/functions/register_nav_menu/) by adding the following to your theme's `functions.php` file.

```php
// create a social media menu
add_action( 'after_setup_theme', 'register_social_media_menu' );

function register_social_media_menu() {
    register_nav_menu( 'social_media', __( 'Socia Media Menu', 'example-theme' ) );
}
```

## 3. Add a Social Media Menu in the WordPress Backend

1. Login to WordPress and add a new menu by navigating to **/wp-admin/nav-menus.php?action=edit&menu=0**
2. Name the menu anything you'd like. In my case, I named the menu **Social Media Menu**

![add social media menu to wordpress](/assets/images/posts/use-dashicons-to-create-a-social-media-menu-in-wordpress/add-social-media-menu-to-wordpress.png)

## 4. Use Dashicon Markup in the Newly Created Menu

1. Navigate to the WordPress [Dashicons page](https://developer.wordpress.org/resource/dashicons) and search for the desired icon. In this example, I will use [Facebook](https://developer.wordpress.org/resource/dashicons/#facebook).
2. Click **Copy HTML** to generate the correct HTML. In my case I get `<span class="dashicons dashicons-facebook"></span>`

![generate dashicon markup](/assets/images/posts/use-dashicons-to-create-a-social-media-menu-in-wordpress/generate-dashicon-markup.png)

3. Navigate back to the menu you create in step **3.1**
4. Add a **Custom Link** to the menu, ensuring you use `<span class="dashicons dashicons-facebook"></span>` as the **Link Text**
    - To be accessible, add `<span class="screen-reader-text">Facebook</span>`. It should now render `<span class="dashicons dashicons-facebook"><span class="screen-reader-text">Facebook</span></span>`. 
        - Make sure your theme has a `screen-reader-text` class as outlined in [The CSS class screen-reader-text](https://make.wordpress.org/accessibility/handbook/markup/the-css-class-screen-reader-text/)

![add dashicon markup to custom menu link.png](/assets/images/posts/use-dashicons-to-create-a-social-media-menu-in-wordpress/add-dashicon-markup-to-custom-menu-link.png)

5. Click **Save Menu**

## 5. Display the Menu in Your Theme

Display the menu in your theme as you see fit. In my case, I chose to display the menu in a **Widget**
