---
title: Batch Upload Field Collection Items to Create an Image Gallery
tags: ["Tutorial", "Media Management"]
categories: ["Drupal 7"]
resources: [{title: "Field collection", url: "https://www.drupal.org/project/field_collection"}, {title: "Field Collection Bulkupload", url: "https://www.drupal.org/project/field_collection_bulkupload"}, {title: "FileField Sources", url: "https://www.drupal.org/project/filefield_sources"}, {title: "Plupload integration", url: "https://www.drupal.org/project/plupload"}, {title: "Entity API", url: "https://www.drupal.org/project/entity"}, {title: "Colorbox", url: "https://www.drupal.org/project/colorbox"}, {title: "Token", url: "https://www.drupal.org/project/token"}, {title: "Libraries API", url: "https://www.drupal.org/project/libraries"}]
date: 2016-06-13
node: 167
---
 
## Introduction and Requirements

Let's say you want to create an image gallery on your site. Let's say that each image also needs a caption and a photo credit field. One solution would be to create a field collection of and image, text and long text field. However, the most image galleries contain many images. It would be very time consuming to have to upload each image individually. Enter [Field Collection Bulkupload](https://www.drupal.org/project/field_collection_bulkupload). With  **Field Collection Bulkupload**  you can drag and drop multiple images onto the page and have them automatically uploaded.

![](/assets/images/posts/batch-upload-field-collection-items-create-image-gallery/field-collection-batch-upload.gif)

> The above images demonstrates how the a content editor can batch upload multiple images into a gallery, with fields for a caption and photo credit.

In this tutorial we are going to go an extra step and have our images appear in a [Colorbox](https://www.drupal.org/project/colorbox) with dynamic captions using the [Token](https://www.drupal.org/project/token) module.

![](/assets/images/posts/batch-upload-field-collection-items-create-image-gallery/field-collection-batch-upload-2.gif)

> The above images shows how the gallery will function for a visitor. The caption and photo credit will appear in the Colorbox.

## Enable Necessary Modules and Libraries

- [Field collection](https://www.drupal.org/project/field_collection)
- [File Field Sources](https://www.drupal.org/project/filefield_sources)
- [Plupload integration module](https://www.drupal.org/project/plupload)
- [Colorbox](https://www.drupal.org/project/colorbox)
- [Entity API](https://www.drupal.org/project/entity)
- Entity tokens
- [Field Collection Bulk Upload](https://www.drupal.org/project/field_collection_bulkupload)
- [Libraries API](https://www.drupal.org/project/libraries)
- [Token](https://www.drupal.org/project/token)

## Add a Field Collection Field

1. Add a  **field collection** field to an existing or new content type. Set the  **widget**  to **Embedded**.
![](/assets/images/posts/batch-upload-field-collection-items-create-image-gallery/1-1-2.png)
2. Set the  **Number of values**  to **Unlimited.**
![](/assets/images/posts/batch-upload-field-collection-items-create-image-gallery/1-2-1.png)
3. Now navigate to the field collection admin page at the following URL **admin/structure/field-collections**
4. Add the followings fields
![](/assets/images/posts/batch-upload-field-collection-items-create-image-gallery/1-3-1.png)

| **LABEL** | **MACHINE NAME** | **FIELD TYPE** | **WIDGET** |
| --------- | ---------------- | -------------- | ---------- |
| Gallery Image | field\_gallery\_image | Image | Image |
| Photo Credit | field\_photo\_credit | Text | Text field |
| Caption | field\_caption | Long text | Text area (multiple rows) |

5. Format their display like this:
![](/assets/images/posts/batch-upload-field-collection-items-create-image-gallery/1-4-0.png)

| **FIELD** | **LABEL** | **FORMAT** |
| --------- | --------- | ---------- |
| Gallery Image | \<Hidden\> | Colorbox |
| Photo Credit | Above | \<Hidden\> |
| Caption | Above | \<Hidden\> |

6. Format the  **Gallery Image** field Colorbox display like this:
    1. **Content image style** = Medium (220x20)
    1. **Content image style for first image** = No special style.
    1. **Colorbox image style** = None (original image)
    1. **Gallery (image grouping)** = Per page gallery
    1. **Caption** = Custom (with tokens)
    1. **​Custom caption** = `[field\_collection\_item:field-caption] | Photo By [field\_collection\_item:field\_photo\_credit]`

![](/assets/images/posts/batch-upload-field-collection-items-create-image-gallery/1-5-0.png)

## Apply Necessary Patches To Fix Bugs

At the time of this writing, I am using  **7.x-1.0-alpha1**  of the [Field Collection Bulk Upload](https://www.drupal.org/project/field_collection_bulkupload) module. This is not a completely stable release, and because of that there are some bugs. However, the following patches take care of the most common issues you may run into.

### Undefined function: filefield\_sources\_save\_file

> The specified file _temporary://p1alhovrrd15flnnrv79t3r1nju7.tmp_ could not be copied, because no file by that name exists. Please check that you supplied the correct filename.

The solution to this problem can be found [here](https://www.drupal.org/node/1892668#comment-9887597). Basically, the Field Collection Bulkupload depends upon the [FileField Sources](https://www.drupal.org/project/filefield_sources) module. Apply [this patch ](https://www.drupal.org/files/issues/undefined_function-1892668-4.patch)to add it as a dependency. Once applied, don't forget to enable the FileField Sources module. 

    cd sites/all/modules/field_collection_bulkupload
    ​wget https://www.drupal.org/files/issues/undefined_function-1892668-4.patch
    patch -p1 < undefined_function-1892668-4.patch

I got an error when trying to apply the patch.

    missing header for context diff at line 3 of patch
    can't find file to patch at input line 3
    Perhaps you used the wrong -p or --strip option?
    The text leading up to this was:
    --------------------------
    |*** field_collection_bulkupload.info.old 2015-05-03 23:40:36.281057385 +0200
    |--- field_collection_bulkupload.info 2015-05-03 23:34:39.902669313 +0200

To fix this, i just selected  **field\_collection\_bulkupload.info**

    File to patch: field_collection_bulkupload.info

Once applied, remove the patch.

    rm undefined_function-1892668-4.patch

### If validation fails, files are lost

If you were to batch upload your files before filling out any required fields on that particular form, the files would immediately be removed. Apply [this patch](https://www.drupal.org/files/issues/field_collection_bulkupload-fix-files-lost-when-validation-fails-1797886-4.patch) from [this issue](https://www.drupal.org/node/1797886#comment-8577413) to solve the problem.

    cd sites/all/modules/field_collection_bulkupload
    ​wget https://www.drupal.org/files/issues/field_collection_bulkupload-fix-files-lost-when-validation-fails-1797886-4.patch
    patch -p1 < field_collection_bulkupload-fix-files-lost-when-validation-fails-1797886-4.patch

Once applied, remove the patch.

    rm field_collection_bulkupload-fix-files-lost-when-validation-fails-1797886-4.patch

### Last existing field collection item disappears

If you were to upload additional items after the initial upload, the last item would be replaced. Apply [this patch](https://www.drupal.org/files/issues/field_collection_bulkupload-fix_last_item_disappearing-2098649-6.patch) from [this issue](https://www.drupal.org/node/2098649#comment-8569763) to solve the problem

    cd sites/all/modules/field_collection_bulkupload
    wget https://www.drupal.org/files/issues/field_collection_bulkupload-fix_last_item_disappearing-2098649-6.patch
    patch -p1 < field_collection_bulkupload-fix_last_item_disappearing-2098649-6.patch

Once applied, remove the patch.

    rm field_collection_bulkupload-fix_last_item_disappearing-2098649-6.patch

## Conclusion and Next Steps

I've always felt that Drupal was never that great at handling media, especially compared to other open source CMS's, like WordPress. When you hand a site off to a client, they're going to want the administrative pages to be as easy to use as possible. Having a media gallery with captions and photo credits is a very common component for a website, and a client would expect to be able to add media easily and quickly. However, if you're not in need of additional fields then you can simply follow my other tutorial on how to [Drag and Drop Batch Upload Files In Drupal](/blog/drag-and-drop-batch-upload-files-drupal).