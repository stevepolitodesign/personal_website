---
title: Drupal Leaflet Not Working [Solved]
tags: ["Quick Tip", "Leaflet", "Solved"]
categories: ["Drupal 7"]
date: 2015-10-29
node: 150
---

The [Leaflet Module](https://www.drupal.org/project/leaflet) for Drupal is probably the most popular mapping module. I was recently working on a project where I was mapping locations and displaying them on a Leaflet map both as a field formatter display and a views attachment. However, I was running into two problems:

1. The Leaflet field formatter was not displaying on nodes
2. The Leaflet views map was not appearing as an attachment

## Make Sure The Leaflet Module and Library Are Installed Correctly

Before you go any further, make sure the module and library are installed correctly. Download that latest stable [Leaflet Library](http://leafletjs.com) and install it at **/sites/all/libraries/leaflet/leaflet.js**. Refer to the [Leaflet Module Documentation](http://cgit.drupalcode.org/leaflet/plain/README.txt?id=refs/heads/7.x-1.x) for detailed instructions.

## Leaflet Map Not Appearing On Node Display

Ok, so now that you've confirmed the library and module are installed correctly, let's debug why the Leaflet map is not appearing on a node display. In order for Leaflet to work properly, you need to have the following modules installed and enabled.

1. [Leaflet](https://www.drupal.org/project/leaflet)
2. [Geocoder](https://www.drupal.org/project/geocoder)
3. [geoPHP](https://www.drupal.org/project/geophp)
4. [Geofield](https://www.drupal.org/project/geofield)
5. [Address Field](https://www.drupal.org/project/addressfield)

Your content type needs to have two fields to geocode an address and display it as a Leaflet map:

1. A **Postal address** field
2. A **Geofield** that is using the **Geocode from another field** widget

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.15.59-AM.png)

The **Geofield** needs to be configured using the following settings:

1. The **Geocode from field** needs to be set with to the **Postal Address** field you have created in this content type

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.16.31-AM.png)

2. Set the **Geocoder** to **Google Geocoder** and use the default settings.

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.16.38-AM.png)

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.16.45-AM.png)

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.16.50-AM.png)

3. Navigate to your content type's display by going to **admin/structure/types/manage/your-custom-content-type/display**
4. Make sure **Leaflet** **Map** is set to a map and **not** --select--

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.07.16-AM.png)

Ok, now that all these settings have been configured, there's a chance that your
map will still not show up. This is because you need to re-save your nodes so
they can be geocoded. This typically is only an issue if you installed Leaflet
after you've created nodes with postal addressees.

I recommend using [Views Bulk Operations (VBO)](https://www.drupal.org/project/views_bulk_operations) to do a batch re-save of all nodes.

![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.28.10-AM.png)

## Leaflet Views Map Not Appearing As An Attachment

It's very common to use a Leaflet Views display to show multiple locations on a Leaflet map, and use a proximity filter to narrow down results. However you might run into an issue where the map doesn't appear as an attachment.

![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.34.15-AM.png)

1. First, make sure the attachment is set to **inherit exposed filters**

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.40.23-AM.png)

2. Make sure you added a location field to the attachment

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.41.23-AM.png)

3. Under the format settings for the Leaflet Map, make sure the **Data Source** is using the location field from step 2.

4. Also make sure there is a map selected.

5. Un-check **Hide empty** just to make sure this is not causing any issues

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.42.03-AM.png)

6. Under **Filter Criteria** make sure there is a proximity filter exposed. Make sure it has the same settings as the proximity filter used on the page this attachment is attached to.

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.44.33-AM.png)

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.44.43-AM.png)

7. **Finally, and most importantly, make sure the Page this attachment is attached to has AJAX turned off.**
8. The attachment itself can have AJAX on, but the page cannot. In my case, this is why my map didn't show up.

   ![](/assets/images/posts/drupal-leaflet-not-working-solved/Screen-Shot-2015-10-29-at-11.45.44-AM.png)

## Still Having Issues? Check Your Logs

Another common issue is the you've exceeded [Google's Query Limit](https://www.drupal.org/node/1672742)
