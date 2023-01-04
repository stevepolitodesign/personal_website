---
title: Learning WordPress as a Drupal Developer
categories: ["WordPress", "Drupal 7"]
date: 2019-05-31
---

I started my career in web development by using Drupal 7 on every project. I just assumed that WordPress could not meet my needs, and that it could not be customized as well as Drupal. However, after working within WordPress for several years, I've learned that WordPress can match Drupal's functionally, and can almost always meet my needs no matter what the project scale.

This is a a guide for any Drupal Developer that wishes to learn WordPress.

| Drupal Concept                                                                                                                                | WordPress Equivalent                                                                                                                           | Notes                                                                  |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| [Views](https://www.drupal.org/project/views)                                                                                                 | [WP_Query](https://developer.wordpress.org/reference/classes/wp_query/)                                                                        | [Read More](#views_wp_query)                                           |
| [Rules](https://www.drupal.org/project/rules)                                                                                                 | [Action Hooks](https://codex.wordpress.org/Plugin_API/Action_Reference)                                                                        | [Read More](#rules_action_hooks)                                       |
| [Blocks](https://www.drupal.org/docs/8/core/modules/block/overview)                                                                           | [Widgets](https://wordpress.org/support/article/wordpress-widgets/)                                                                            | [Read More](#blocks_widgets)                                           |
| [Roles and Permissions](https://www.drupal.org/docs/7/managing-users/user-roles)                                                              | [Members Plugin](https://wordpress.org/plugins/members/)                                                                                       | [Read More](#roles_permissions_members_plugin)                         |
| [Custom Content Types](https://www.drupal.org/docs/7/nodes-content-types-and-fields/create-a-custom-content-type)                             | [register_post_type](https://developer.wordpress.org/reference/functions/register_post_type/) and [ACF](https://www.advancedcustomfields.com/) | [Read More](#custom_post_types_register_post_type_acf)                 |
| [Vocabularies](https://www.drupal.org/docs/7/organizing-content-with-taxonomies/create-a-vocabulary)                                          | [register_taxonomy](https://codex.wordpress.org/Function_Reference/register_taxonomy)                                                          | [Read More](#vocabularies_register_taxonomy)                           |
| [Field Collection Module](https://www.drupal.org/project/field_collection) and [Paragraphs Module](https://www.drupal.org/project/paragraphs) | [ACF Flexible Content](https://www.advancedcustomfields.com/resources/flexible-content/)                                                       | [Read More](#field-collection-paragraphs-modules-acf-flexible-content) |
| [drush](https://www.drush.org/)                                                                                                               | [wp_cli](https://wp-cli.org/)                                                                                                                  | [Read More](#drush_wp_cli)                                             |
| [Zen Theme](https://www.drupal.org/project/zen)                                                                                               | [Underscores Theme](https://underscores.me/)                                                                                                   | [Read More](#zen_underscores)                                          |

<a name="views_wp_query"></a>

## Views => WP_Query

Arguably the most powerful Drupal feature is [Views](https://www.drupal.org/project/views). Views lets a site builder create complex database queries without having to write any SQL, or know anything about databases. It also allows site builders to create advanced search features based on user input. If you're like me, then you probably didn't realize WordPress offers the same functionality. However, they key difference is that you write your queries using the [WP_Query](https://developer.wordpress.org/reference/classes/wp_query/) API.

If you're coming from Drupal, this might seem foreign. However, there are a lot of advantages to writing you're own queries instead of relying on a module.

**Advantages**

- Complete control of the output markup. Drupal Views adds a lot of bloat.
- Changes are stored in the codebase. This means they are saved in version control. You don't need to worry about exporting views, or creating [Features](https://www.drupal.org/project/features).
- More secure (this is my opinion). The only way to create, edit or delete a custom query is if you have access to the codebase, unlike Drupal.

**Examples**

- [Create a Custom Search Form in WordPress](/blog/create-a-custom-search-form-in-wordpress/)
- [Create a Proximity Search in WordPress](/blog/create-a-proximity-search-in-wordpress/)

<a name="rules_action_hooks"></a>

## Rules => Action Hooks

Another powerful Drupal feature is [Rules](https://www.drupal.org/project/rules). The Rules module allows site administrators to define conditionally executed actions based on occurring events. For example, using Rules, a site builder could trigger an email to be sent every time a new post is created, or display a custom message once a user signs in.

However, the same functionality can be achieved in WordPress using the [Action Hooks](https://codex.wordpress.org/Plugin_API/Action_Reference) API. The main difference is that you code these conditional triggers instead of building them via a UI.

**Advantages**

- Changes are stored in the codebase. This means they are saved in version control. You don't need to worry about exporting rules, or creating [Features](https://www.drupal.org/project/features).
- More secure (this is my opinion). The only way to create, edit or delete a custom Rule is if you have access to the codebase, unlike Drupal.

**Examples**

- [Email Admins When a Post is Submitted in WordPress](/blog/wordpress-acf-front-end-form-tutorial/#alert-admins-when-a-new-recipe-has-been-submitted)

<a name="blocks_widgets"></a>

## Blocks => Widgets

Drupal has the concept of [Blocks](https://www.drupal.org/docs/8/core/modules/block/overview), which are boxes of content rendered into an area, or region, of a web page. WordPress has the same concept, only they're called [Widgets](https://wordpress.org/support/article/wordpress-widgets/).

There's not a big difference between Drupal Blocks and WordPress Widgets, but it's important to know that both CMSs offer the same functionality.

**Advantages**

- You have more control over the markup of Widgets compared to Blocks.
- Cleaner markup.

<a name="roles_permissions_members_plugin"></a>

## Roles and Permissions => Members Plugin

By default, Drupal has a very robust [Roles and Permissions](https://www.drupal.org/docs/7/managing-users/user-roles) system baked in. In my opinion, WordPress Core is lacking in this area. However, the [Members Plugin](https://wordpress.org/plugins/members/) will add some familiar functionality to your WordPress install.

I've personally had great luck using this plugin when building small to medium sized sites that needed a more customized authorization system.

<a name="custom_post_types_register_post_type_acf"></a>

## Custom Content Types => register_post_type and ACF

Drupal lets site builders easily create [Custom Content Types](https://www.drupal.org/docs/7/nodes-content-types-and-fields/create-a-custom-content-type). WordPress Core makes this a _little_ more difficult. WordPress has the [register_post_type](https://developer.wordpress.org/reference/functions/register_post_type/) API, which allows you to create a custom post type. However, you need to either use a [plugin](https://wordpress.org/plugins/custom-post-type-ui/), or use the [wp cli](https://developer.wordpress.org/cli/commands/scaffold/post-type/). **I strongly recommend using the [wp cli](https://developer.wordpress.org/cli/commands/scaffold/post-type/)** since it's one less plugin to install, and you can save your post types into version control. However, the **register_post_type** API is not enough in most cases. You'll also want to install [ACF](https://www.advancedcustomfields.com/) in order to add fields to your new custom post type. **ACF** is a staple in the WordPress ecosystem, just like Views is a staple for Drupal 7.

**Examples**

- [Create a Custom Search Form in WordPress](/blog/create-a-custom-search-form-in-wordpress/)
- [Create a Recipe Post Type in WordPress](/blog/wordpress-acf-front-end-form-tutorial/#recipe-custom-post-type)

<a name="vocabularies_register_taxonomy"></a>

## Vocabularies => register_taxonomy

Drupal lets site builders easily create [Vocabularies](https://www.drupal.org/docs/7/organizing-content-with-taxonomies/create-a-vocabulary). WordPress Core makes this a _little_ more difficult. WordPress has the [register_taxonomy](https://codex.wordpress.org/Function_Reference/register_taxonomy) API, which allows you to create a custom taxonomy. However, you need to either use a [plugin](https://wordpress.org/plugins/custom-post-type-ui/), or use the [wp cli](https://developer.wordpress.org/cli/commands/scaffold/taxonomy/). **I strongly recommend using the [wp cli](https://developer.wordpress.org/cli/commands/scaffold/taxonomy/)** since it's one less plugin to install, and you can save your taxonomies into version control.

**Examples**

- [Create a Recipe Post Type in WordPress](/blog/wordpress-acf-front-end-form-tutorial/#recipe-custom-taxonomy)

<a name="field-collection-paragraphs-modules-acf-flexible-content"></a>

## Field Collection and Paragraphs Modules => ACF Flexible Content

Drupal allows site builders to build dynamic layouts using a combination of the [Field Collection Module](https://www.drupal.org/project/field_collection) and the [Paragraphs Module](https://www.drupal.org/project/paragraphs). WordPress has a similar paradigm in the form of [ACF Flexible Content](https://www.advancedcustomfields.com/resources/flexible-content/). Unfortunately this is paid solution, but it's **well worth the purchase**, and also the only real alternative if you're coming from Drupal.

It's important to note that WordPress now ships with [Gutenberg](https://wordpress.org/gutenberg/), which is a visual editor. This might solve your layout needs as well.

<a name="drush_wp_cli"></a>

## drush => wp_cli

Drupal has a command line tool called [drush](https://www.drush.org/). WordPress has an equivalent called [wp_cli](https://wp-cli.org/). Both are CMS specific, and are very helpful. If you depend upon drush for your Drupal development, then you'll come to love the wp_cli if you're working in WordPress.

<a name="zen_underscores"></a>

## Zen Theme => Underscores Theme

Most Drupal themers use the [Zen Theme](https://www.drupal.org/project/zen) as a base theme. The WordPress equivalent is [Underscores Theme](https://underscores.me/).

**Advantages**

- Underscores is developed by the same [team](https://automattic.com/) that builds WordPress. This means it's stable, and is guaranteed to meet follow practices and meet compatibility standards.

**Examples**

- [Modern WordPress Theme Development in 2019](/blog/modern-wordpress-theme-development-2019/)
- [Create a Bootstrap Theme for WordPress](/blog/create-a-bootstrap-theme-for-wordpress/)
