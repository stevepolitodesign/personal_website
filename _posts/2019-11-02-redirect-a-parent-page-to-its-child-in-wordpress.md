---
title: Redirect a Parent Page to its Child in WordPress
categories: ["WordPress"]
resources: [
    {
        title: "wp_redirect()",
        url: "https://developer.wordpress.org/reference/functions/wp_redirect/"
    }
]
date: 2019-11-02
---

Sometimes you need to redirect a parent page to its child page, especially if you need to keep a specific type of menu hierarchy. There are several ways to do this, but I prefer using [Advanced Custom Fields](https://www.advancedcustomfields.com/). This is because it allows content editors control over the redirect, and also allows for greater flexibility in the future.

{% youtube "https://www.youtube.com/embed/uMuLUqOoB_Q" %}

## 1. Create a New Template

First create a new page template. The name doesn't matter, but I like to call mine `Redirector` so as to be expressive.

```php
// redirector.php
<?php
/*
* Template Name: Redirector
*/
```

## 2. Assign the Parent Page This New Template

In order for the parent page to have the ability to redirect, we need to assign it to the new template we just created.

![Parent page template assignment](/assets/images/posts/redirect-a-parent-page-to-its-child-in-wordpress/parent-page-template-assignment.png)

## 3. Create a New Field Group with a Link Field

Next we need to create a field to store the url that will act as the redirect. Using [Advanced Custom Fields](https://www.advancedcustomfields.com/), create a new field group.

- Add a `Link` field that is `Required`, and set the "Return Value" to `Link URL`
- Show this field group if `Post Template` is equal to `Redirector`

![ACF Redirector Field Configuration](/assets/images/posts/redirect-a-parent-page-to-its-child-in-wordpress/acf-redirector-field-configuration.png)

## 4. Add a Value to the Link Field

Edit the parent page, and assign the newly created link field a value. You can actually assign it any link you wish, but try assigning it to its child page.

![Parent page link value](/assets/images/posts/redirect-a-parent-page-to-its-child-in-wordpress/parent-page-link-value.png)

## 5. Update the Redirector Template

The redirector template needs to then take the value from the link field and actually perform a redirect. We'll use the [wp_redirect()](https://developer.wordpress.org/reference/functions/wp_redirect/) function to do this. Make us to end the statement with `exit;`. Finally, make sure to conditionally check if there's a value set to the link field. If there's no value, redirect to another page. In my case, I just redirect to the home page.

```php{7-15}
// redirector.php
<?php
/*
* Template Name: Redirector
*/

$url = get_field('redirector');

if($url) {
    wp_redirect( $url );
    exit;
} else {
    wp_redirect( home_url() );
    exit;
}
```
