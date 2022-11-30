---
title: Create a Reddit Style Website In Drupal
tags: ["Tutorial", "Views", "Rate"]
categories: ["Drupal 7"]
resources: [{title: "ShrinkToWeb Registration", url: "http://www.shrinktheweb.com/"}, {title: "ShrinkToWeb", url: "https://www.drupal.org/project/shrinktheweb"}, {title: "Link", url: "https://www.drupal.org/project/link"}, {title: "Rate", url: "https://www.drupal.org/project/rate"}, {title: "Views", url: "https://www.drupal.org/project/views"}]
date: 2015-09-08
node: 145
---
 
Sites that allow users to post and vote on content such as [Reddit](http://reddit.com) and [Digg](http://digg.com) are hugely successful. In this tutorial we are going to create a Reddit style website in Drupal. What do I mean by "Reddit style website"?

1. A user can post a link to an external URL.
1. Users can upvote or downvote posted content.
1. The content will appear displaying an automatically generated thumbnail from the external website.
1. Users can filter results based on the content's rating and when it was posted.

Below is a screenshot of what we will be creating.

![](/assets/images/posts/create-reddit-style-website-drupal/reddit-home.gif)

## Step 1: Configure ShrinkTheWeb

One of the nice things about Reddit is that is automatically creates a thumbnail of the website a user links to. This is helpful because it gives users a sneak peak at what they are about to visit.

Luckily, [ShrinkTheWeb](https://www.drupal.org/project/shrinktheweb) is a module that does just this.

1. [Create a free account](https://www.shrinktheweb.com/user/register) at ShrinkTheWeb.
2. After you register, go to the [home tab](http://www.shrinktheweb.com/auth/stw-lobby) and do the following:
3. Copy your **Access Key**  and **Secret Key**

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-10.40-censor.jpg)

4. Add your domains to  **My Allowed Domains & IPs:**  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-10.41-censor.jpg)

5. Now that you have an account, install and enable the [ShrinkTheWeb](https://www.drupal.org/project/shrinktheweb) module.
6. Navigate to  **admin/config/media/shrinktheweb**
7. Add your  **Access Key**  and  **Secret Key** from step 3

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-10.42-censor.jpg)

8. (Optional) Set the size of the  **Default Thumbnail size**  to  **xlg**. This is the largest you can make the generated thumbnail with the free plan.  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-10.42.46-AM.png)

## Step 2: Create a Link Content Type

Now that we configured ShrinkTheWeb, we can create a new custom content type. This will allow users to post links to external URLs.

1. Before you create a new custom content type, install and enable the [Link module](https://www.drupal.org/project/link).
2. Create a new content type by going to  **admin/structure/types/add**
3. Name your custom content type and adjust any configurations as you see fit.  
 
![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-10.47.43-AM.png)

4. Add a link field and make it required.  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-10.48.40-AM.png)  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-10.49.07-AM.png)

5. Under the teaser display  **admin/structure/types/manage/your-new-content-type/display/teaser** set the **Link** label to  **Hidden** and the format to **[ShrinkTheWeb] Separate title and URL**.  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-09-at-8.12.33-PM_0.png)

## Step 3: Configure Rate Module

Now that we have the content type configured, we need to add the ability for users to rate content.

1. Install and enable the [Rate module](https://www.drupal.org/project/rate)
2. Navigate to  **admin/structure/rate/**  and add a  **Number up / down**  widget.  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-09-at-8.26.46-PM.png)

3. On the next page, name your widget and configure the following settings:  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-09-at-8.27.01-PM.png)

4. Under  **NODE TYPES**  select the content type you created in Step 2  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-6.17.31-PM.png)

5. Under  **DISPLAY SETTINGS**  make sure  **Display in teaser**  is checked, and  **Appearance in teaser**  is set to  **Full widget.**  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-6.39.48-PM.png)

6. Under  **INTERACTION**  set  **Which rating should be displayed?** to  **Average rating**. Set ** Which rating should be displayed when the user just voted?**  to  **Average rating**. Set S **hould a second click on the same button delete the vote?**  to **No**.  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-6.18.22-PM.png)

7. Under  **PERMISSIONS**  set  **Roles** to  **authenticated** user and any other role you wish to grant this permission to. Check  **Allow author to rate his / her own content**. Set  **Behaviour when user has no permission to vote** to **Redirect to login and show message**.  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-6.18.57-PM.png)

## Step 4: Configure The View

Now we have everything we need to create a view that will display our content and allow users to sort based in specific criteria.

1. First, install and enable [Views](https://www.drupal.org/project/views).
2. Then, create a new view by going to  **admin/structure/views/add**
3. Configure the view to show **Content**  of the content type you created in **Step 2: Create a Link Content Type**  **sorted by unsorted.**  Create a  **page**  of **teasers.**  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-6.34.44-PM.png)

4. Under  **RELATIONSHIPS** add a  **Content: Vote results** relationship.
    1. Set the  **Value type** to **points**
    2. Set the **Vote tag** to **Normal Vote**
    3. Set the  **Aggregation function** to **Average vote**  
 
![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-10-at-6.00.08-AM.png)

5. Under  **FILTER CRITERIA** add a  **Content: Post date** field.
    1. Select  **Expose this filter to visitors, to allow them to change it**
    2. Under  **Filter type to expose** select ** Grouped filters**
    3. Under  **Widget type** chose **Select**  
    4. Add the following filters
    5. Today, Is greater than or equal to, An offset from the current time,  - 24 hours
    6. This Week, Is greater than or equal to, An offset from the current time,  - 7 days
    7. This Month, Is greater than or equal to, An offset from the current time,  - 1 month
    8. This Year, Is greater than or equal to, An offset from the current time,  - 1 year
    9. All Time, Is greater than or equal to, An offset from the current time,  - 999 years      
  
![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-6.32.29-PM.png)

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-10-at-5.49.10-AM.png)

6. Under  **SORT CRITERIA** add **Vote results: Value**
    1. Select  **Expose this sort to visitors, to allow them to change it**
    2. Relationship  **Vote results**
    3. Select  **Sort descending**
    4. Check  **Treat missing votes as zeros**  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-6.27.53-PM.png)

7. ​Under Under  **SORT CRITERIA** add **Content: Post date**
    1. ​Select  **Expose this sort to visitors, to allow them to change it**
    2. Select   **Sort descending**
    3. Under  **Granularity** select  **Second**  

![](/assets/images/posts/create-reddit-style-website-drupal/Screen-Shot-2015-09-07-at-6.28.42-PM.png)

8. Save your view

You can then set the path of this view to be the homepage of your website at  **admin/config/system/site-information**

## Conclusion

This is just a bare bones example of how to create a Reddit style website. There's obviously more to Reddit than just the above, but the ability for users to post and rate content is crucial. Adding the ShrinkToWeb functionality is a nice touch and adds an extra layer of detail. If you're looking to use the features we created today more than once, you can always create an [installation profile](http://salsadigital.com.au/news/drupal-installation-profile-and-distributions) as outlined by [Awang Setiawan](mailto:salsadigital.au@gmail.com).
