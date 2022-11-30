---
title: "Pro Tip: Use the esc_attr Function to Format alt Tags When Using ACF"
categories: ["WordPress"]
tags: ["ACF"]
resources: [
    {
        title: "Data Sanitization/Escaping",
        url: "https://developer.wordpress.org/themes/theme-security/data-sanitization-escaping/#escaping-securing-output"
    },
    {
        title: "ACF Image",
        url: "https://www.advancedcustomfields.com/resources/image/"
    },
    {
        title: "Zapp Brannigan mispronouncing champagne",
        url: "https://www.youtube.com/watch?v=FPyFRa39AMk"
    }
]
date: 2019-06-13
---

## Intro

> Originally this article recommended using the [htmlentities](https://www.php.net/manual/en/function.htmlentities.php) function. However, after a lot of helpful feedback, I've learned it's best practice to use [esc_attr](https://developer.wordpress.org/reference/functions/esc_attr/)

If you're [rendering images with ACF](https://www.advancedcustomfields.com/resources/image/), make sure you run the `alt` text against the ~~htmlentities~~ [esc_attr](https://developer.wordpress.org/reference/functions/esc_attr/) function. Why? Because there's a chance that the `alt` text could contain quotation marks `""`. 

![acf image field setup](/assets/images/posts/use-esc_attr-to-format-alt-tags/1.1.png)

If it does, it will break the formatting of the `alt` tag as seen below.

## Before

![example of incorrectly formatted alt tag](/assets/images/posts/use-esc_attr-to-format-alt-tags/1.2.png)

```php
<?php
	$image = get_field('banner_image');
	$url = esc_url($image['url']);
	$alt = $image['alt'];
?>
...
<img src="<?php echo $url; ?>" alt="<?php echo $alt; ?>" />
```

```html
<img src="..." alt="Zapp Brannigan drinking " champaggan""="">
```

## After

![example of correctly formatted alt tag using esc_attr](/assets/images/posts/use-esc_attr-to-format-alt-tags/1.3.png)

```php{4}
<?php
	$image = get_field('banner_image');
	$url = esc_url($image['url']);
	$alt = esc_attr($image['alt']);
?>
...
<img src="<?php echo $url; ?>" alt="<?php echo $alt; ?>" />
```
```html
<img src="..." alt="Zapp Brannigan drinking &quot;Champaggan&quot;">
```
