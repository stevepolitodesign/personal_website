---
title: Create Live Search Results (Search as You Type) in Drupal
tags: ["Tutorial", "Search"]
categories: ["Drupal 7"]
resources: [{title: "Search API", url: "https://www.drupal.org/project/search_api"}, {title: "Search API Autocomplete", url: "https://www.drupal.org/project/search_api_autocomplete"}, {title: "Search API live results", url: "https://www.drupal.org/project/search_api_live_results"}]
date: 2015-10-22
node: 149
---

By default, Drupal offers the ability to search the site with its core **Search**  module. However, this module can be limiting. In this tutorial we are going to configure live results. Below is the final result. When a user begins to type, live results will appear that are linked to a node.

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/live-search-1.gif)

## Enable the Modules

1. Navigate to the modules page and enable the following modules.
    - Database search
    - Search API
    - Search API autocomplete
    - Search live results
    - Search pages
 
 ![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-5.39.25-AM.png)

2. Disable the core Search module  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-6.16.41-AM.png)

## Add A Server To Search

1. Navigate to the Search API configuration page **admin/config/search/search\_api**
2. Click  **Add server**, or go to **admin/config/search/search\_api/add\_server**

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-5.41.28-AM.png)

3. Give the server a name, and make sure to check **Enabled**  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-5.41.56-AM.png)

4. Select **Database service**  for the server class. The default settings can be used for everything else.  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-5.42.10-AM.png)

5. Edit the  **Default node index** at **admin/config/search/search\_api/index/default\_node\_index/edit**

6. Under  **Server** select the server you just created in step 2 and click save.  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-5.46.06-AM.png)

7. Navigate to **admin/config/search/search\_api/index/default\_node\_index** and click  **enable**  in the status row.  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-5.47.51-AM.png)

8. Once enabled, click **Index now**  to index all content on your site.  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-23-at-6.31.55-AM.png)

9. Under the  **Fields**  tab or **admin/config/search/search\_api/index/default\_node\_index/fields**, select the fields and other data you wish your site to be able to search. In my case, I only have the default  **Basic Page**  and  **Article**  content types enabled on my site. Because of this, I made sure to have the  **tags**  field searchable, along with the  **summary**  of each content type which is stored in the  **body**  field.  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-5.50.25-AM.png)

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-5.50.48-AM.png)  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-23-at-6.27.13-AM.png)

## Add A Search Page​

1. Navigate to the Search API Search Pages page at **admin/config/search/search\_api/page**
2. Click  **Add search page**  or go to **admin/config/search/search\_api/page/add**
 
![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-5.55.40-AM.png)

3. Set the  **Index**  to the  **Default node index** we enabled in the previous section

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-6.06.48-AM.png)

4. Set the path for the search page. In my case I kept it simple and used **search**.

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-6.06.59-AM.png)

## Configure Live Search Settings

1. Navigate back to the  **Default node index** page at **admin/config/search/search\_api/index/default\_node\_index**
2. Click the  **Autocomplete**  tab at **admin/config/search/search\_api/index/default\_node\_index/autocomplete**
3. Enable  **Global Site Search**  that we created in step 4 and click  **Save**  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-6.11.42-AM.png)

4. Click the  **Live Results** tab at **admin/config/search/search\_api/index/default\_node\_index/live-results**
5. Enable  **Global Site Search**  that we created in step 9 and click  **Save**  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-6.11.42-AM.png)

6. (​Optional) Click edit to adjust how many live results will appear when running a search. You can also select  **Use view mode: 'Live result search' to display results.**  Instead of simply displaying the title of the node on the search box, this will display the content based on your configuration of the  **Live result search**  display format. For now, I'll just use **Only show title (linked to node)**.  
 
 ![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-6.12.17-AM.png)

## Configure Search API Permissions

1. Navigate to **admin/people/permissions** and grant the appropriate roles these permissions.
2. Use autocomplete for the Global Site Search search
3. Use live result search
4. Access Global Site Search search page  

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-22-at-6.17.48-AM.png)

## Enable the Search Block

Users can now search the site at **/search**, but let's make it even easier for them by adding a search block to the header.

1. Navigate to the blocks page at **admin/structure/block**
2. A search block with the name we used in step 3 of  **Add A Search Page​** will be available.
3. Add this block to the header, or any other region

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-23-at-6.43.24-AM.png)

## Optional: Show Node Content In Live Search

The above steps allow users to search as they type by displaying node titles. However, we can also display node content while users search too. This is perfect for e-commerce sites, but can be used almost anywhere. Below is the effect we are after. Note that you will need to use custom CSS to style this.

![](/assets/images/posts/create-live-search-results-search-you-type-drupal/Screen-Shot-2015-10-25-at-8.34.25-AM.png)

1. Navigate to the **Manage display** tab for any content type being indexed. Then, go to the **Live results search** display. For an Article, that would be **admin/structure/types/manage/article/display/live\_results\_search**.
2. Configure the fields you wish to display and save.
3. Navigate to the **Live Results Tab** for the Default node index we configured earlier, or go to **admin/config/search/search\_api/index/default\_node\_index/live-results**
4. Click **edit**  next to **Global Site Search**
5. Under **Display Method**  enable  **Use view mode: 'Live result search' to display results**  and save.
6. You will need to style these search results using CSS. Each theme is different, so I will leave this step out. You could also use [Panelizer](https://www.drupal.org/project/panelizer) to help with this.