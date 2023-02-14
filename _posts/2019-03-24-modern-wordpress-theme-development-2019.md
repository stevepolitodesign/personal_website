---
title: Modern WordPress Theme Development in 2019
categories: ["WordPress"]
tags: ["Theming"]
resources:
  [
    {
      title: "WP-CLI: Command line interface for WordPress",
      url: "https://wp-cli.org/",
    },
    { title: "Underscores Theme", url: "https://underscores.me/" },
    { title: "WPGulp", url: "https://github.com/ahmadawais/WPGulp" },
    { title: "SMACSS", url: "https://smacss.com/book/categorizing" },
    { title: "BEM", url: "http://getbem.com/introduction/" },
    { title: "typebase.css", url: "https://github.com/devinhunt/typebase.css" },
    {
      title: "Semantic UI Container",
      url: "https://semantic-ui.com/elements/container.html",
    },
    {
      title: "Semantic UI Grid",
      url: "https://semantic-ui.com/collections/grid.html",
    },
    {
      title: "Theme Unit Test",
      url: "https://codex.wordpress.org/Theme_Unit_Test#Many_Categories_.26_Many_Tags",
    },
  ]
date: 2019-03-24
---

In this article I'm going to show you my personal and opinionated WordPress theme development workflow. The goal of this article is to highlight the power of the [WordPress Command Line](https://wp-cli.org/) when combined with [automated build tools](https://github.com/ahmadawais/WPGulp), along with an organized project structure.

## 0. Install the WordPress Command Line

The [WordPress Command Line](https://wp-cli.org/) is a **Command line interface for WordPress**. Simply put, this means that it can automate many tasks for us. One task is generating a starter theme. However, it can do [much, much more](https://developer.wordpress.org/cli/commands/).

## 1. Use the WordPress Command Line To Generate a New Starter Theme

Once you've [installed](https://wp-cli.org/#installing) the CLI, follow these steps to generate a base theme.

1. In the root of your WordPress install, run `wp scaffold _s slug_for_your_theme --activate`. For the case of this tutorial, I will run `wp scaffold _s demo-theme --activate`.
   - The [wp scaffold \_s function](https://developer.wordpress.org/cli/commands/scaffold/_s/) **generates starter code for a theme based on \_s (Underscores)**.
   - The [Underscores Theme](https://underscores.me/) is created by [Automatic](https://automattic.com/), which is the same company that brings us WordPress. By default, it generates all files and directories needed for a valid WordPress theme.
   - Note that you can manually download the [Underscores Theme](https://underscores.me/), but using the CLI is much more effective.

If you navigate to the front end of your website, you should notice an underwhelming theme.

![default underscores theme](/assets/images/posts/modern-wordpress-theme-development-2019/1.1.png)

As underwhelming as it is, this starter theme meets all of WordPress's [theme development standards](https://codex.wordpress.org/Theme_Development#Theme_Development_Standards). In short, this means that all the necessary templates, functions and css are generated for you.

![_s theme directory](/assets/images/posts/modern-wordpress-theme-development-2019/1.2.png)

If you were to run your theme against the [Theme Check](https://wordpress.org/plugins/theme-check/) plugin and its **6,108** tests, you'll only get 2 warnings. One is about a hidden file that is generated, and the other is about changing the Theme URI and Author URI. However, these only matter if you plan on publishing your theme to WordPress.

> I like to run my theme against Theme Check throughout the development process to ensure any changes I make still meet **WordPress's theme development standards.**

![Theme Check results on _s theme](/assets/images/posts/modern-wordpress-theme-development-2019/1.3.png)

At this point you _could_ start editing the `style.css` and template files to build your custom theme. However, it's much more effective to use modern build tools to speed up development.

## 2. Install and Configure WPGulp

Now that we have a base theme configured, we'll want it to be customized with our own CSS, JS and template files. Using a build tool like [WPGulp](https://github.com/ahmadawais/WPGulp) helps speed up this process.

> WPGulp is an advanced & extensively documented Gulp.js + WordPress workflow. It can help you kick-start a build-workflow for your WordPress plugins and themes with Gulp.js, save you a lot of grunt work time, follow the DRY (Don't Repeat Yourself) principle, and #0CJS Zero-config JavaScript startup but still configurable via wpgulp.config.js file...

You can read about all of what [WPGulp does](https://github.com/ahmadawais/WPGulp#-wpgulp-can-do-that), but some of my favorite features are...

- Hot reloading
- ES6 compiling
- SASS compiling
- Automatic image minification
- Compiles all JS and CSS into one file each

1. Follow the docs to [install WPGulp](https://github.com/ahmadawais/WPGulp#-step-1--download-the-required-files).
   1. In my case I `cd` into my theme by running `cd wp-content/themes/demo-theme/`.
   1. I then run `npx wpgulp`.
1. Once installation is complete, you'll want to edit the `wpgulp.config.js` file.
   1. Change the `projectURL: 'wpgulp.local'` variable to match your local development URL.
   1. If you plan on translating your site, make sure to update the **translation options**.

## 3. Update Your Theme's File Structure To Work With WPGulp

Now that WPGulp is installed and configured, we'll want to update our theme's file structure to match the recommendations in the `wpgulp.config.js`. These updates are based on the `styleSRC`, `jsVendorSRC`, `jsCustomSRC` and `imgSRC` variables.

1. Assuming you're still in your theme's directory, run the following commands.
   1. `mkdir -p assets/css assets/js/vendor assets/js/custom assets/img/raw`
1. Now that the file structure matches the `wpgulp.config.js` configuration, we'll want to move existing `.css` and `.js` files by running the following commands.
   1. `mv style.css assets/css/style.scss`
      - This moves the theme's `style.css` file into the `assets/css`, and also changes it to a `.scss` file.
   1. `mv layouts/ assets/css/layouts`
      - This moves the theme's generated `layout` directory into `assets/css/`
   1. `mv assets/css/layouts/sidebar-content.css assets/css/layouts/sidebar-content.scss`
   1. `mv assets/css/layouts/content-sidebar.css assets/css/layouts/content-sidebar.scss`
      - These commands change the `.css` files into `.scss` files.
      - Note that these are boilerplate layout files generated by the `wp scaffold _s` command, and that they were never loaded into the theme in the first place. If you want to use one of them, you'll need to import it into the `styles.scss` file. I personally never use them.
   1. `mv js/customizer.js assets/js/custom/customizer.js`
   1. `mv js/navigation.js assets/js/custom/navigation.js`
   1. `mv js/skip-link-focus-fix.js assets/js/custom/skip-link-focus-fix.js`
   1. `rm -R js/`
      - These commands simply move existing javascript files generated by the `wp scaffold _s` command into the new javascript directory.

At this point your `assets` directory should look like this.

![WPGulp assets directory structure](/assets/images/posts/modern-wordpress-theme-development-2019/2.1.png)

## 4. Update functions.php

Now that the `assets` directory is configured, we'll need to update the theme's `functions.php` file.

1. Open up your theme's `functions.php` file and scroll down to the **Enqueue scripts and styles.** section. It should look something like this.

   ```php
   /**
    * Enqueue scripts and styles.
    */
   function demo_theme_scripts()
   {
     wp_enqueue_style("demo-theme-style", get_stylesheet_uri());

     wp_enqueue_script(
       "demo-theme-navigation",
       get_template_directory_uri() . "/js/navigation.js",
       [],
       "20151215",
       true
     );

     wp_enqueue_script(
       "demo-theme-skip-link-focus-fix",
       get_template_directory_uri() . "/js/skip-link-focus-fix.js",
       [],
       "20151215",
       true
     );

     if (is_singular() && comments_open() && get_option("thread_comments")) {
       wp_enqueue_script("comment-reply");
     }
   }
   add_action("wp_enqueue_scripts", "demo_theme_scripts");
   ```

   WPGulp will concatenate all javascript files in the `assets/js/custom` and `assets/js/vendor` directories into one file each. This means that we don't need to individually load `navigation.js` and `skip-link-focus-fix.js` anymore. Note that these files were generated by the `wp scaffold _s` command, and aren't required for every WordPress theme.

2. remove the existing `wp_enqueue_script` functions and replace with the following.
   - i've commented out the vendor scripts, since we currently have none. i just wanted to highlight how you would load them.
   - i added `'customize-preview'` as an argument to the `wp_enqueue_script` function for the custom-scripts. this is because the `/assets/js/custom/customizer.js` file generated by the `wp scaffold _s` is [only loaded on the theme customizer page](https://codex.wordpress.org/plugin_api/action_reference/customize_preview_init).
   - i chose to load the `.min` versions of each file, but you can load the unminified versions if you wish.
   - the `vendor.min.js` and `custom.min.js` files will be generated once we run wpgulp.

  <pre data-line="9-19">
    <code class="language-php">
      /**
       * enqueue scripts and styles.
       */
      function demo_theme_scripts()
      {
        wp_enqueue_style("demo-theme-style", get_stylesheet_uri());
      
        // vendor scripts. only uncomment if you have files in assets/js/vendor
        // wp_enqueue_script( 'demo-theme-vendor-scripts', get_template_directory_uri() . '/assets/js/vendor.min.js', array(), '20151215', true );
        // custom demo_theme_scripts
        // note that we pass 'customize-preview' into the array();
        wp_enqueue_script(
          "demo-theme-custom-scripts",
          get_template_directory_uri() . "/assets/js/custom.min.js",
          ["customize-preview"],
          "20151215",
          true
        );
      
        if (is_singular() && comments_open() && get_option("thread_comments")) {
          wp_enqueue_script("comment-reply");
        }
      }
      add_action("wp_enqueue_scripts", "demo_theme_scripts");
    </code>
  </pre>

3. Run `npm start` to make sure everything is working. You should be able to open up **http://localhost:3000/** and see your site. To ensure everything is hooked up, I temporarily added `* { border: 1px solid red; }` to `/assets/css/style.scss`. You should see the new styles load instantly in the browser.

!['testing WPGulp'](/assets/images/posts/modern-wordpress-theme-development-2019/2.2.png)

4. I also recommend checking the **sources** and **console** tabs on Chrome's developer tools to ensure there are no errors, and that all files are being loaded.

![chrome sources tab](/assets/images/posts/modern-wordpress-theme-development-2019/2.3.png)

![chrome console tab](/assets/images/posts/modern-wordpress-theme-development-2019/2.4.png)

At this point you have everything you need to start creating a custom WordPress theme using modern developer tools. In the next sections I will show you my opinionated setup.

## 5. Create a CSS Architecture

This next step details my opinionated set up when it comes to my CSS Architecture. I subscribe to the [SMACSS](https://smacss.com/book/categorizing) way of architecting my CSS, along with the [BEM](http://getbem.com/introduction/) naming convention. This may seem like an obsolete way of doing things if you're coming from a frontend framework or library like React, Vue, Angular etc. However, WordPress isn't a frontend framework, so paradigms like [CSS Modules](https://github.com/css-modules/css-modules) or [Styled Components](https://github.com/styled-components/styled-components) don't apply.

> At the end of the day, we're compiling many `.scss` files into one `.css` file. Using SMACSS is an excellent way to stay organized and efficient.

1. Assuming you're in your theme's directory, run the following commands:
1. `mkdir -p assets/css/base assets/css/layouts assets/css/module`
   - This follows the [SMACSS](https://smacss.com/book/categorizing) way of architecting CSS. I usually just create these three directories, and don't use [state](https://smacss.com/book/type-state) or [theme](https://smacss.com/book/type-theme) rules. Instead, I create many partials in the **modules** directory, and use the [BEM](http://getbem.com/introduction/) naming convention.
1. `touch assets/css/base/_base.scss assets/css/base/_var.scss`
   - This creates two new partials. One for storing SASS variables, and the other for base styles.
1. Copy everything from `/assets/css/style.scss` and into `/assets/css/base/_base.scss`
1. Remove everything from `/assets/css/style.scss` and replace with the following:

```scss
// base
@import "./base/var";
@import "./base/base";
```

If you run `npm start` you should notice no changes. This is because we didn't change any css, but instead broke it into partials. From here on out you'll import your partials into `style.scss`.

## 6. Add a Typography System

Now that we've set up an architecture for our CSS, I like to add a typography system to the theme. I use [typebase.css](https://github.com/devinhunt/typebase.css) because of its simplicity, and use of SASS variables.

1. Assuming you're in your theme's directory, run the following commands:
   1. `touch assets/css/base/_typography.scss`
1. Open `/assets/css/style.scss` and look for the **Typography** section. It should start look something like this:

   ```css
   body,
   button,
   input,
   select,
   optgroup,
   textarea {
     color: #404040;
     font-family: sans-serif;
     font-size: 16px;
     font-size: 1rem;
     line-height: 1.5;
   }

   h1,
   h2,
   h3,
   h4,
   h5,
   h6 {
     clear: both;
   }
   ```

1. Remove the typography css from `style.scss`. For me this is between lines 389 and 455 - The reason we remove the default typography styles provided by the Underscores Theme is because we will be using [typebase.css](https://github.com/devinhunt/typebase.css) instead. 4. Open up `_typography.scss` and paste in the contents from the [typebase.scss file](https://raw.githubusercontent.com/devinhunt/typebase.css/master/src/typebase.scss). However, don't paste in the **Typesetting variables**. We will place these in the `assets/css/base/_var.scss` file instead.

   ```css
   html {
     font-family: serif;
     font-size: $baseFontSize / 16 100%;
     // Make everything look a little nicer in webkit
     -webkit-font-smoothing: antialiased;
     // -webkit-text-size-adjust: auto
     // -moz-text-size-adjust: auto
     // -ms-text-size-adjust: auto
     // -o-text-size-adjust: auto
     // text-size-adjust: auto
   }

   p {
     line-height: $leading;
     margin-top: $leading;
     margin-bottom: 0;
   }
   ul,
   ol {
     margin-top: $leading;
     margin-bottom: $leading;
     li {
       line-height: $leading;
     }
     ul,
     ol {
       margin-top: 0;
       margin-bottom: 0;
     }
   }
   blockquote {
     line-height: $leading;
     margin-top: $leading;
     margin-bottom: $leading;
   }

   h1,
   h2,
   h3,
   h4,
   h5,
   h6 {
     font-family: sans-serif;
     margin-top: $leading;
     margin-bottom: 0;
     line-height: $leading;
   }
   h1 {
     font-size: 3 _ $scale _ 1rem;
     line-height: 3 _ $leading;
     margin-top: 2 _ $leading;
   }
   h2 {
     font-size: 2 _ $scale _ 1rem;
     line-height: 2 _ $leading;
     margin-top: 2 _ $leading;
   }
   h3 {
     font-size: 1 _ $scale _ 1rem;
   }
   h4 {
     font-size: $scale / 2 _ 1rem;
   }
   h5 {
     font-size: $scale / 3 _ 1rem;
   }
   h6 {
     font-size: $scale / 4 _ 1rem;
   }

   table {
     margin-top: $leading;
     border-spacing: 0px;
     border-collapse: collapse;
   }
   td,
   th {
     padding: 0;
     line-height: $baseLineHeight _ $baseFontSize - 0px;
   }

   code {
     // Forces text to constrain to the line-height. Not ideal, but works.
     vertical-align: bottom;
   }

   .lead {
     font-size: $scale _ 1rem;
   }

   .hug {
     margin-top: 0;
   }
   ```

1. Open up `assets/css/base/_var.scss` and paste in the **Typesetting variables** from [typebase.scss file](https://raw.githubusercontent.com/devinhunt/typebase.css/master/src/typebase.scss)].

   ```scss
   // Typesetting variables. Edit here or override in main file prior to import of this.
   $baseFontSize: 22 !default; // in pixels. This would result in 22px on desktop
   $baseLineHeight: 1.5 !default; // how large the line height is as a multiple of font size
   $leading: $baseLineHeight \* 1rem !default;
   // Rate of growth for headings
   // I actually like this to be slightly smaller then the leading. Makes for tight headings.
   $scale: 1.414 !default;
   ```

1. Finally, import `/assets/css/base/_typograhpy.scss` into `/assets/css/style.scss`

   ```scss
   // base
   @import "./base/var";
   @import "./base/base";
   @import "./base/typography";
   ```

If you run `npm start` and open your browser, you should see something like this.

![tyebase.css default size](/assets/images/posts/modern-wordpress-theme-development-2019/6.1.png)

The default size is usually too big for me, so I set `$baseFontSize:22 !default;` to `16` instead.

## 7. Add a Grid System

Next I like to add a grid system to my theme. Some argue that this is unnecessary because of [CSS Grid](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Grid_Layout), but I've found that having a simple grid system is very helpful.

I highly recommend using [Semantic UI Container](https://semantic-ui.com/elements/container.html) and [Semantic UI Grid](https://semantic-ui.com/collections/grid.html) because of its easy naming conventions and use of flex-box instead of floats.

1. First, we need to remove the default layout files that were generated and updated in steps 3.2.2 through 3.2.4. Assuming you're still in your theme's directory, run `rm assets/css/layouts/sidebar-content.scss assets/css/layouts/content-sidebar.scss`.
1. Run `touch assets/css/layouts/_container.scss`.
1. Copy the contents from [container.css](https://raw.githubusercontent.com/Semantic-Org/UI-Container/master/container.css) and paste into `/assets/css/layouts/_container.scss`.
1. Run `touch assets/css/layouts/_grid.scss`.
1. Copy the contents from [grid.css](https://raw.githubusercontent.com/Semantic-Org/UI-Grid/master/grid.css) and paste into `/assets/css/layouts/_grid.scss`.
1. Open up `/assets/css/base/_var.scss` and add the following SASS variables:

   - These are the breakpoints defined in the [Semantic UI Container](https://semantic-ui.com/elements/container.html). Adding these breakpoints as variables is useful when writing custom media queries for your theme.

   ```scss
   // Typesetting variables. Edit here or override in main file prior to import of this.
   $baseFontSize: 16 !default; // in pixels. This would result in 22px on desktop
   $baseLineHeight: 1.5 !default; // how large the line height is as a multiple of font size
   $leading: $baseLineHeight \* 1rem !default;
   // Rate of growth for headings
   // I actually like this to be slightly smaller then the leading. Makes for tight headings.
   $scale: 1.414 !default;

   // breakpoints
   // from device width https://semantic-ui.com/elements/container.html
   $bp--sm: 768px;
   $bp--md: 992px;
   $bp--lg: 1200px;
   ```

1. Finally, import `assets/css/layouts/_container.scss` and `assets/css/layouts/_grid.scss` into `/assets/css/style.scss`.

   ```scss
   // base
   @import "./base/var";
   @import "./base/base";
   @import "./base/typography";

   // layouts
   @import "./layouts/container";
   @import "./layouts/grid";
   ```

As a test, add `.ui.container` classes to the `#masthead` and `#content` in `wp-content/themes/demo-theme/header.php`.

```php
<?php
/**
 * The header for our theme
 *
 * This is the template that displays all of the <head> section and everything up until <div id="content">
 *
 * @link https://developer.wordpress.org/themes/basics/template-files/#template-partials
 *
 * @package Demo-theme
 */
?>
<!doctype html>
<html <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo("charset"); ?>">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="profile" href="https://gmpg.org/xfn/11">

    <?php wp_head(); ?>

</head>

<body <?php body_class(); ?>>
<div id="page" class="site">
<a class="skip-link screen-reader-text" href="#content"><?php esc_html_e(
  "Skip to content",
  "demo-theme"
); ?></a>

    <header id="masthead" class="site-header ui container">
    <div class="site-branding">
    <?php
    the_custom_logo();
    if (is_front_page() && is_home()): ?>
    <h1 class="site-title"><a href="<?php echo esc_url(
      home_url("/")
    ); ?>" rel="home"><?php bloginfo("name"); ?></a></h1>
    <?php else: ?>
    <p class="site-title"><a href="<?php echo esc_url(
      home_url("/")
    ); ?>" rel="home"><?php bloginfo("name"); ?></a></p>
    <?php endif;
    $demo_theme_description = get_bloginfo("description", "display");
    if ($demo_theme_description || is_customize_preview()): ?>
    <p class="site-description"><?php echo $demo_theme_description;
      /* WPCS: xss ok. */
      ?></p>
    <?php endif;
    ?>
    </div><!-- .site-branding -->

    <nav id="site-navigation" class="main-navigation">
    <button class="menu-toggle" aria-controls="primary-menu" aria-expanded="false"><?php esc_html_e(
      "Primary Menu",
      "demo-theme"
    ); ?></button>
    <?php wp_nav_menu([
      "theme_location" => "menu-1",
      "menu_id" => "primary-menu",
    ]); ?>
    </nav><!-- #site-navigation -->
    </header><!-- #masthead -->

    <div id="content" class="site-content ui container">
```

The content should now have a max width

![semantic ui container](/assets/images/posts/modern-wordpress-theme-development-2019/7.1.png)

## Conclusion and Next Steps

Regardless of what the design looks like, I start every custom WordPress theme with the above steps. From there I add color variables, and begin to style the header and footer first. I always [populate the site with dummy data](https://codex.wordpress.org/Theme_Unit_Test#Many_Categories_.26_Many_Tags) so that I can style each unique page template, and account for edge cases.
