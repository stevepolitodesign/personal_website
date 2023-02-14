---
title: Customize a Video Thumbnail in Drupal
tags: ["Media", "Tutorial", "Video"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Media", url: "https://www.drupal.org/project/media" },
    {
      title: "Media: YouTube",
      url: "https://www.drupal.org/project/media_youtube",
    },
    {
      title: "Entity view modes",
      url: "https://www.drupal.org/project/entity_view_mode",
    },
    {
      title: "ImageCache Actions",
      url: "https://www.drupal.org/project/imagecache_actions",
    },
  ]
date: 2016-07-23
node: 169
---

## Introduction and Requirements

When you upload a video to Drupal from YouTube or Vimeo, an automatically generated thumbnail will be created. This is normally not a big deal, but wouldn't it be nice if you could have complete control over the thumbnail that is associated with the video? Thankfully, with Drupal's [File Entity](https://www.drupal.org/project/file_entity) module, you can. In this tutorial, we will add the ability to add a custom video thumbnail to a video in Drupal. As an added bonus, we will use the [ImageCache Actions](https://www.drupal.org/project/imagecache_actions) module to automatically add a play button to each video thumbnail.

![](/assets/images/posts/customize-video-thumbnail-drupal/1.1_3.png)

> The above image shows how Drupal automatically generates a thumbnail for videos uploaded from YouTube or Vimeo

![](/assets/images/posts/customize-video-thumbnail-drupal/1.2_2.png)

> The above image shows how we can create a custom thumbnail for a video uploaded from YouTube or Vimeo

## Enable Necessary Modules

- [Media](https://www.drupal.org/project/media)
- [Media: YouTube](https://www.drupal.org/project/media_youtube)
- [Entity view modes](https://www.drupal.org/project/entity_view_mode)
- [ImageCache Actions](https://www.drupal.org/project/imagecache_actions)
- Imagecache Canvas Actions

## Add a Video Thumbnail Field to the Video File Type

1. Add a new video thumbnail field to the **Video File Type** by going to **/admin/structure/file-types/manage/video/fields**
1. Configure the field using the following settings:

   | **Label** | **Machine Name** | **Field Type** | **Widget**    |
   | --------- | ---------------- | -------------- | ------------- |
   | Thumbnail | field_thumbnail  | Image          | Media browser |

- **Required field** = enabled
- **Enabled browser plugins** = Upload, Library
- **Allowed file types** = Image
- **Allowed URI schemes** = Public files
- **Number of values** = 1

![](/assets/images/posts/customize-video-thumbnail-drupal/2.2_1.png)

![](/assets/images/posts/customize-video-thumbnail-drupal/2.3_1.png)

## Add a New View Mode for the Video File Type

1. Add a new entity view mode for the video file type by going to **/admin/config/system/entity-view-modes/add/file**

   - **Label** = Video Thumbnail
   - **Use custom display settings** = enabled
   - **Enable this view mode for the following types** = Video

   ![](/assets/images/posts/customize-video-thumbnail-drupal/3.1_1.png)

2. Update the display mode for the new view mode you just created

   /admin/structure/file-types/manage/video/display/video_thumbnail

   | FIELD     | LABEL      | FORMAT                              |
   | --------- | ---------- | ----------------------------------- |
   | Thumbnail | \<Hidden\> | Image Image style: Medium (220x220) |

   ![](/assets/images/posts/customize-video-thumbnail-drupal/3.2_1.png)

3. Finally, update the view mode of the video field.

   | Field | LABEL      | FORMAT                                   |
   | ----- | ---------- | ---------------------------------------- |
   | Video | \<Hidden\> | Rendered file View mode: Video Thumbnail |

   ![](/assets/images/posts/customize-video-thumbnail-drupal/3.3_0.png)

## Add a Custom Thumbnail to an Existing Video

1. Navigate to an existing video by going to **/admin/content/file**
1. Upload a custom file to be used as the video thumbnail

   ![](/assets/images/posts/customize-video-thumbnail-drupal/4.2_0.png)

## Automatically Add Play Button to the Custom Video Thumbnail (Optional)

1. Create a new image style by going to **/admin/config/media/image-styles/add**

   ![](/assets/images/posts/customize-video-thumbnail-drupal/5.1.png)

2. Add a **scale** effect and set it to **220x220**

   ![](/assets/images/posts/customize-video-thumbnail-drupal/5.2.png)

3. Add a **Overlay (watermark)** effect and set it to the following:

   - **X offset** = center
   - **Y offset** = center
   - **opacity** = 100%
   - **file name** = path to your custom file

   ![](/assets/images/posts/customize-video-thumbnail-drupal/5.3.png)

4. Update the video file type display to use the new **Video Thumbnail** image style by going to **/admin/structure/file-types/manage/video/display/video_thumbnail**

   ![](/assets/images/posts/customize-video-thumbnail-drupal/5.4.png)

   ![](/assets/images/posts/customize-video-thumbnail-drupal/5.5.png)

> The above image shows how we can create a custom thumbnail that automatically adds a play button for a video uploaded from YouTube or Vimeo
