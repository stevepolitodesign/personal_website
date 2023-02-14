---
title: Create a Custom Search Form in WordPress
tags: ["Search"]
categories: ["WordPress"]
date: 2019-01-21
resources:
  [
    {
      title: "WordPress Query Vars",
      url: "https://codex.wordpress.org/WordPress_Query_Vars",
    },
    {
      title: "Custom Query Vars",
      url: "https://codex.wordpress.org/Function_Reference/get_query_var#Custom_Query_Vars",
    },
    {
      title: "pre_get_posts action API",
      url: "https://codex.wordpress.org/Plugin_API/Action_Reference/pre_get_posts",
    },
    {
      title: "Query posts by custom fields",
      url: "https://www.advancedcustomfields.com/resources/query-posts-custom-fields/",
    },
    {
      title: "Taxonomy Parameters",
      url: "https://codex.wordpress.org/Class_Reference/WP_Query#Taxonomy_Parameters",
    },
    {
      title: "Querying relationship fields",
      url: "https://www.advancedcustomfields.com/resources/querying-relationship-fields/",
    },
  ]
---

In this tutorial we are going to create a custom search form in WordPress. Specifically, we are going to add a custom search form on the **archive** of a **custom post type**.

> Below is the final result.

![custom search form in WordPress](/assets/images/posts/create-a-custom-search-form-in-wordpress/demo-1.gif)

## 0. Initial Set Up (Optional)

This tutorial is going to cover searching against a custom post type tagged with a custom taxonomy, custom fields, and relational data. For context, my setup is below.

- A **director** custom post type
- A **movie_category** custom taxonomy
- A **movie** custom post type
  - A **rating** custom field
  - A **director** custom relational field
  - The ability to **categorize** each **movie** with the **movie_category** custom taxonomy

## 1. Add Custom Query Vars

WordPress has the concept of [Query Vars](https://codex.wordpress.org/WordPress_Query_Vars). By default, WordPress ships with several dozen **Public** and **Private** **Query Vars**.

> Query vars are fed into WP_Query, WordPress' post querying API. Public query vars can be used in the URL querystring. Private query vars cannot.

Since public query vars can be passed into the URL, we can alter the current loop just by appending the URL. For example, if you navigate to the **blog page** for a WordPress site and pass `?s=test` into the URL, the loop will show all posts that contain **test** in the title or description.

Wouldn't it be nice if we could search against custom fields, related content and other data? For example, what if I wanted to search for all **movies** that have at least a 3 star **rating**? I can't just add `?rating=3` to the URL and expect it to work.

> In order to for WordPress to recognize these custom parameters, we need to create [Custom Query Vars](https://codex.wordpress.org/Function_Reference/get_query_var#Custom_Query_Vars).

1. Open your theme's **functions.php** file and enter the following.

```php
/**
 * Create Custom Query Vars
 * https://codex.wordpress.org/Function_Reference/get_query_var#Custom_Query_Vars
 */
function add_query_vars_filter($vars)
{
  // add custom query vars that will be public
  // https://codex.wordpress.org/WordPress_Query_Vars
  $vars[] .= "director_id";
  $vars[] .= "rating";
  $vars[] .= "movie_category_ids";
  return $vars;
}
add_filter("query_vars", "add_query_vars_filter");
```

What's happening here? The **query_vars** filter allows you to register new custom **query vars**. This means that WordPress will now recognize the **director_id**, **rating** and **movie_category_ids** if they're used in the URL as parameters.

> You can name these **custom query vars** anything you want. However, the names of these **custom query vars** cannot conflict with existing [Query Vars](https://codex.wordpress.org/WordPress_Query_Vars#List_of_Query_Vars).

## 2. Override The Archive Query Served By WordPress

In my example, we are going to add a search form to the **archive** of a **custom post type**. I'm doing this because I personally thinks its a cleaner solution because...

1. By default, WordPress automatically generates an archive page.
1. The URL structure is clean. In my example, the archive url is **/movie/**. That means that when I append the URL, it will look like this **/movie/?rating=3**

   In order to override an existing query, we need to use the [pre_get_posts action](https://codex.wordpress.org/Plugin_API/Action_Reference/pre_get_posts).

1. Open your theme's **functions.php** file and enter the following.

   ```php
   /**
    * Override Movie Archive Query
    * https://codex.wordpress.org/Plugin_API/Action_Reference/pre_get_posts
    */
   function movie_archive($query)
   {
     // only run this query if we're on the movie archive page and not on the admin side
     if (
       $query->is_archive("movie") &&
       $query->is_main_query() &&
       !is_admin()
     ) {
       // get query vars from url.
       // https://codex.wordpress.org/Function_Reference/get_query_var#Examples

       // example.com/movie/?rating=4
       $rating = get_query_var("rating", false);
       // example.com/movie/?director_id=14
       $director = get_query_var("director_id", false);
       // example.com/movie/?movie_category_ids[]=6
       $category = get_query_var("movie_category_ids", false);

       // used to conditionally build the meta_query
       // the meta_query is used for searching against custom fields
       $meta_query_array = ["relation" => "AND"];

       // conditionally add arrays to the meta_query based on values in the URL
       // the `key` is the name of my custom fields
       $director
         ? array_push($meta_query_array, [
           "key" => "director",
           "value" => '"' . $director . '"',
           "compare" => "LIKE",
         ])
         : null;
       $rating
         ? array_push($meta_query_array, [
           "key" => "rating",
           "value" => $rating,
           "compare" => ">=",
         ])
         : null;

       // final meta_query
       $query->set("meta_query", $meta_query_array);

       // used to conditionally build the tax_query
       // the tax_query is used for a custom taxonomy assigned to the post type
       // i'm using the `'relation' => 'OR'` to make the search more broad
       $tax_query_array = ["relation" => "OR"];

       // conditionally add arrays to the tax_query based on values in the URL
       // `movie_category` is the name of my custom taxonomy
       $category
         ? array_push($tax_query_array, [
           "taxonomy" => "movie_category",
           "field" => "term_id",
           "terms" => $category,
         ])
         : null;

       // final tax_query
       $query->set("tax_query", $tax_query_array);
     }
   }
   add_action("pre_get_posts", "movie_archive");
   ```

   So, what's going on with this function?

1. First, we make sure this function will only run on the **movie** archive page. We also make sure this query does not affect admin pages by adding **!is_admin()** to the conditional.

   - You can update this conditional to meet your needs. Make sure to reference the [pre_get_posts action API](https://codex.wordpress.org/Plugin_API/Action_Reference/pre_get_posts).

   ```php
   if ( $query->is_archive('movie') && $query->is_main_query() && !is_admin() )
   ```

1. Next, we save the **query_vars** passed into the URL.

   - We use the [get_query_var function](https://codex.wordpress.org/Function_Reference/get_query_var) to get the value of each **custom query_vars** passed into the URL. I set the second parameter of the function to **FALSE** in order to conditionally set a **meta_query** later in the function.

   ```php
   // example.com/movie/?rating=4
   $rating = get_query_var("rating", false);
   // example.com/movie/?director_id=14
   $director = get_query_var("director_id", false);
   // example.com/movie/?movie_category_ids[]=6
   $category = get_query_var("movie_category_ids", false);
   ```

1. Next, we conditionally build a [meta_query](https://www.advancedcustomfields.com/resources/query-posts-custom-fields/) to search against the custom fields.

   - What we do here is see if either the **director_id** or **rating** **custom query_vars** exist in the URL. If they do, we append them to the **$meta_query_array** array.
   - Advanced Custom Fields allows you to easily [Query relationship fields](https://www.advancedcustomfields.com/resources/querying-relationship-fields/)
   - The **meta_query** is not specific to Advanced Custom Fields, but this is a common pattern.

   ```php
   // used to conditionally build the meta_query
   // the meta_query is used for searching against custom fields
   $meta_query_array = ["relation" => "AND"];

   // conditionally add arrays to the meta_query based on values in the URL
   // the `key` is the name of my custom fields
   $director
     ? array_push($meta_query_array, [
       "key" => "director",
       "value" => '"' . $director . '"',
       "compare" => "LIKE",
     ])
     : null;
   $rating
     ? array_push($meta_query_array, [
       "key" => "rating",
       "value" => $rating,
       "compare" => ">=",
     ])
     : null;

   // final meta_query
   $query->set("meta_query", $meta_query_array);
   ```

1. Following a similar pattern to step 2.3, we conditionally build a [tax_query](https://codex.wordpress.org/Class_Reference/WP_Query#Taxonomy_Parameters).

   - What we do here is see if the **category** **custom query_vars** exist in the URL. If it does, we append the values to the **$tax_query_array** array.
   - I chose to use a **'relation' => 'OR'** to make searches more broad. This means that a user can select multiple terms, and any post assigned to those terms will appear. If we set **'relation' => 'AND'** a post would only appear if it was assigned to ALL selected terms.

   ```php
   // used to conditionally build the tax_query
   // the tax_query is used for a custom taxonomy assigned to the post type
   // i'm using the `'relation' => 'OR'` to make the search more broad
   $tax_query_array = ["relation" => "OR"];

   // conditionally add arrays to the tax_query based on values in the URL
   // `movie_category` is the name of my custom taxonomy
   $category
     ? array_push($tax_query_array, [
       "taxonomy" => "movie_category",
       "field" => "term_id",
       "terms" => $category,
     ])
     : null;

   // final tax_query
   $query->set("tax_query", $tax_query_array);
   ```

## 3. Add a Search Form to the Archive

Now that we have a way to dynamically affect queries, we need a way for a user to append the correct parameters to the URL. Fortunately, this is very easy to do using a simple HTML form.

1. Create a custom template for the archive. In my case, I created a **archive-movie.php** file. This is necessary since the search form will be specific to the **movie** post type.
1. Add a form with a corresponding input for each **custom query_vars**.

```php
<form method="GET" action="<?php echo get_post_type_archive_link("movie"); ?>">
    <!-- gather data to use in form fields  -->
    <?php
    $directors = new WP_Query([
      "post_type" => "director",
      "posts_per_page" => -1,
    ]);
    $categories = get_terms([
      "taxonomy" => "movie_category",
      "hide_empty" => false,
    ]);
    ?>
    <div>
    <?php if ($directors->have_posts()) { ?>
        <!--  'name' must match the custom query var -->
        <label for="director_id">Director</label>
        <select name="director_id" id="director_id">
            <!-- add a blank option -->
            <option value="">--Any--</option>
            <!-- create an `<option>` for each director -->
            <?php while ($directors->have_posts()) { ?>
                <?php $directors->the_post(); ?>
                <!-- use the ID as the value. this is needed for the meta_query -->
                <option value="<?php echo the_ID(); ?>" <?php echo get_the_ID() ==
get_query_var("director_id", false)
  ? "selected"
  : null; ?>><?php echo the_title(); ?></option>
            <?php } ?>
        </select>
    <?php } ?>
    <?php wp_reset_postdata(); ?>
        <label for="rating">Minimum Rating</label>
        <!-- 'name' must match the custom query var -->
        <select name="rating" id="rating">
            <option value="">--Any--</option>
            <option value="1" <?php echo get_query_var("rating", false) == 1
              ? "selected"
              : null; ?>>1 Star</option>
            <option value="2" <?php echo get_query_var("rating", false) == 2
              ? "selected"
              : null; ?>>2 Stars</option>
            <option value="3" <?php echo get_query_var("rating", false) == 3
              ? "selected"
              : null; ?>>3 Stars</option>
            <option value="4" <?php echo get_query_var("rating", false) == 4
              ? "selected"
              : null; ?>>4 Stars</option>
            <option value="5" <?php echo get_query_var("rating", false) == 5
              ? "selected"
              : null; ?>>5 Stars</option>
        </select>
    </div>
    <?php if (!empty($categories)) { ?>
        <div>
        <?php foreach ($categories as &$category) { ?>
            <!-- 'name' must match the custom query var -->
            <!-- we add `[]` to `movie_category_ids` in order to read the results as an array -->
            <input
                type="checkbox"
                id="<?php echo $category->name; ?>"
                value="<?php echo $category->term_id; ?>"
                name="movie_category_ids[]"
                <?php echo in_array(
                  $category->term_id,
                  get_query_var("movie_category_ids", false)
                )
                  ? "checked"
                  : null; ?>
            />
            <label for="<?php echo $category->name; ?>"><?php echo $category->name; ?></label>
        <?php } ?>
        </div>
    <?php } ?>
    <div >
        <button>Search</button>
        <a href="<?php echo get_post_type_archive_link("movie"); ?>">Reset</a>
    </div>
</form>
```

At first it seems like there is a lot going on, but it's actually fairly simple.

- First, I make sure to set the form **method** to **GET** and the form **action** to `<?php echo get_post_type_archive_link('movie'); ?>`. This ensures the form will update the URL parameters on the correct page.

  - The form **action** is specific to this tutorial. You will need to adjust this URL on your site.

- Next, we create two loops. One **$directors** and the other **$categories**. This is simply to dynamically create the **options** and **checkboxes** for the **Director** select list, and the **Category** checkboxes.
  - This ensures that every new **Category** or **Director** added to the site will be added to the search form.

```php
$directors = new WP_Query([
  "post_type" => "director",
  "posts_per_page" => -1,
]);
$categories = get_terms([
  "taxonomy" => "movie_category",
  "hide_empty" => false,
]);
```

- Then we need to loop through each array and dynamically create the correct input fields.
  - Pay special attention to the **name** attribute of each field. It needs to match the name of the **custom query_var** we created in step 1.1
  - The **value** of each input needs to be in a format the **pre_get_posts function** expects. For example `$director ? array_push($meta_query_array, array('key' => 'director', 'value' => '"' . $director . '"', 'compare' => 'LIKE') ) : null ;` is expecting **$director** to be the **ID**. I know this because of the [this is how you query relationship fields](https://www.advancedcustomfields.com/resources/querying-relationship-fields/).
  - Finally, I conditionally set the **selected** and **checked** values of each input. This is to ensure the values persist once a search is made.

> I added a `[]` to `movie_category_ids` to allow for more than one option to be selected. This will turn the values for the `movie_category_id` key into an array. This is needed for the `$tax_query_array` we created in step 2.4

```php
<?php if ($directors->have_posts()) { ?>

    <!--  'name' must match the custom query var -->
    <label for="director_id">Director</label>
    <select name="director_id" id="director_id">
        <!-- add a blank option -->
        <option value="">--Any--</option>
        <!-- create an `<option>` for each director -->
        <?php while ($directors->have_posts()) { ?>
            <?php $directors->the_post(); ?>
            <!-- use the ID as the value. this is needed for the meta_query -->
            <option value="<?php echo the_ID(); ?>" <?php echo get_the_ID() ==
get_query_var("director_id", false)
  ? "selected"
  : null; ?>``><?php echo the_title(); ?></option>
        <?php } ?>
    </select>

<?php } ?>
<?php wp_reset_postdata(); ?>



<?php if (!empty($categories)) { ?>

    <div>
    <?php foreach ($categories as &$category) { ?>
        <!-- 'name' must match the custom query var -->
        <!-- we add `[]` to `movie_category_ids` in order to read the results as an array -->
        <input
            type="checkbox"
            id="<?php echo $category->name; ?>"
            value="<?php echo $category->term_id; ?>"
            name="movie_category_ids[]"
            <?php echo in_array(
              $category->term_id,
              get_query_var("movie_category_ids", false)
            )
              ? "checked"
              : null; ?>
        />
        <label for="<?php echo $category->name; ?>"><?php echo $category->name; ?></label>
    <?php } ?>
    </div>

<?php } ?>
```

- Finally, I manually add a **select** for the **movie rating**.
  - Since I know there are only 5 possible values for this custom field, I wrote everything out instead of making a loop.
  - I conditionally set the **selected** value to ensure the values persist once a search is made.

```php
<label for="rating">Minimum Rating</label>

<!-- 'name' must match the custom query var -->
<select name="rating" id="rating">
    <option value="">--Any--</option>
    <option value="1" <?php echo get_query_var("rating", false) == 1
      ? "selected"
      : null; ?>>1 Star</option>
    <option value="2" <?php echo get_query_var("rating", false) == 2
      ? "selected"
      : null; ?>>2 Stars</option>
    <option value="3" <?php echo get_query_var("rating", false) == 3
      ? "selected"
      : null; ?>>3 Stars</option>
    <option value="4" <?php echo get_query_var("rating", false) == 4
      ? "selected"
      : null; ?>>4 Stars</option>
    <option value="5" <?php echo get_query_var("rating", false) == 5
      ? "selected"
      : null; ?>>5 Stars</option>
</select>
```

Go ahead and make a search. You should see the **custom query_vars** appended to the URL.

![url with custom custom query_vars](/assets/images/posts/create-a-custom-search-form-in-wordpress/3.1.png)

![search form that sets custom query_vars](/assets/images/posts/create-a-custom-search-form-in-wordpress/3.2.png)

It's important to note that I updated the markup for my loop to be in a table format.

> Pro Tip: Add `<?php global $wp_query; print_r($wp_query); ?>` to the page in order to inspect a the actual query. This is helpful when debugging.

![inspecting a Wordress query](/assets/images/posts/create-a-custom-search-form-in-wordpress/3.3.png)

## TL;DR

If you want to add a custom search to your WordPress site, follow this pattern.

1. Register any [Custom Query Vars](https://codex.wordpress.org/Function_Reference/get_query_var#Custom_Query_Vars) you want to use in a search. Remember that WordPress ships with [Public Query Vars](https://codex.wordpress.org/WordPress_Query_Vars).
2. I recommend adding the search to an [Archive Template](https://codex.wordpress.org/Creating_an_Archive_Index#The_Template_.28archive.php.29), since you get this for free automatically. Instead of creating a new query, just update the existing **archive** query with the [pre_get_posts action API](https://codex.wordpress.org/Plugin_API/Action_Reference/pre_get_posts).
   - Use the [get_query_var function](https://codex.wordpress.org/Function_Reference/get_query_var) to get any **custom query vars** or **public query vars** from the URL, and insert their values into the **pre_get_posts** function as needed.
3. Add a form to the archive template.
   - Be sure the **name** attribute of each field matched the name of the **custom query vars** you created.
   - Be sure the **value** of each field is dynamically created.
