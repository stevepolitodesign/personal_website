---
title: Drag and Drop Batch Upload Files In Drupal
tags: ["Tutorial", "Media Management"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Media  (7.x-1.5)", url: "https://www.drupal.org/project/media" },
    {
      title: "Plupload integration",
      url: "https://www.drupal.org/project/plupload",
    },
    {
      title: "Plupload Library",
      url: "https://github.com/moxiecode/plupload/archive/v1.5.8.zip",
    },
    {
      title: "Drag &amp; Drop Upload",
      url: "https://www.drupal.org/project/dragndrop_upload",
    },
    {
      title: "Multiupload Filefield Widget",
      url: "https://www.drupal.org/project/multiupload_filefield_widget",
    },
  ]
date: 2015-07-16
node: 143
---

I love Drupal, but its media handling is far from ideal. Out of the box, it pales in comparison to WordPress. Most notably, Drupal does not make it easy to batch upload files via a drag and drop interface.

Fortunately, this functionality can be configured with little effort.

## Drag and Drop Batch Upload files with Plupload

If you’re using the [Media Module](https://www.drupal.org/project/media), you’re only able to run a batch upload by uploading the files to the server, and running an import here **admin/content/file/import** (if you’re using the 7.x-1.5 branch).

Although I would recommend this method for uploading hundreds of files at once, it’s not practical for everyday use.

Instead, it would be nice to drag and drop files onto the browser to upload them. Below is what we are going to achieve.

![](/assets/images/posts/drag-and-drop-batch-upload-files-drupal/ddu-1.gif)

First, you will need to download the [Media Module](https://www.drupal.org/project/media).

> NOTE: I am using the Other Release (7.x-1.5).

Next, you will need to download and enable [Plupload integration](https://www.drupal.org/project/plupload). Then, install the [Plupload Library](https://github.com/moxiecode/plupload/archive/v1.5.8.zip) at **sites/all/libraries/plupload**. At the time of this post, I am using v1.5.8. It’s recommended that you delete the “example” directory. Remember, you will also need to have [Libraries API](https://www.drupal.org/project/libraries) installed and enabled as well.

Now, enable the following modules. Note that enabling these modules will enable their dependencies.

- Plupload integration module
- Media Bulk Upload
- Multiple forms

Ok, now navigate to **admin/content/file**. You can either click **Add files** and select multiple files by holding shift.

![](/assets/images/posts/drag-and-drop-batch-upload-files-drupal/ddu-4.gif)

Or, you can simply drag and drop the files into the browser as demonstrated in the beginning of the tutorial.

Click **Start upload** and **Next**. On the subsequent pages you can edit the image properties.

## Drag and Drop Batch Upload Files to an Image Field

Similar to the last section, we are going to create the ability to drag and drop batch upload files to an image field on a content type.

You will need to install and enable the following modules.

- [Drag & Drop Upload](https://www.drupal.org/project/dragndrop_upload)
- [Multiupload Filefield Widget](https://www.drupal.org/project/multiupload_filefield_widget)

For this tutorial, I will use the default Article content type that ships with Drupal Core. However, you can apply this to any image field on your site.

Navigate to the image field’s widget type **admin/structure/types/manage/article/fields/field_image/widget-type** and select **Drag & Drop Upload**.

![](/assets/images/posts/drag-and-drop-batch-upload-files-drupal/Screen-Shot-2015-07-15-at-7.26.52-PM.png)

Now navigate the edit tab for that field **admin/structure/types/manage/article/fields/field_image**. Under **IMAGE FIELD SETTINGS** select **Unlimited** for **Number of values**. Click save.

![](/assets/images/posts/drag-and-drop-batch-upload-files-drupal/Screen-Shot-2015-07-15-at-7.14.21-PM.png)

Navigate back to the edit page **dmin/structure/types/manage/article/fields/field_image**. Under **DRAG & DROP UPLOAD SETTINGS** make sure **Show Browse button** and **Allow multiupload** are checked off. Click save.

![](/assets/images/posts/drag-and-drop-batch-upload-files-drupal/Screen-Shot-2015-07-15-at-7.14.09-PM.png)

> NOTE. I ran into an issue where I would get a WSOD when enabling **Use Media browser**. This seems to be a bug when using the 7.x-1.5 release of the Media module. When I used the stable release, I did not have any issues.

Now you can upload multiple files by dragging them into the browser.

![](/assets/images/posts/drag-and-drop-batch-upload-files-drupal/ddu-3.gif)

You can also select and upload multiple files by holding shift.

![](/assets/images/posts/drag-and-drop-batch-upload-files-drupal/ddu-2.gif)
