---
title: Configure Drupal's Search API to Search Field Collections and Paragraphs
excerpt:
  This tutorial will assume that you are somewhat familiar with the Search API
  module. It also assumes you are using the Search API with the Search API
  Database Search and Search API Pages modules. The goal here is to ensure
  paragraph and field collection fields are being indexed by Search API and
  associated with their host node.
tags: ["Search", "Search API", "Tutorial"]
categories: ["Drupal 7"]
resources:
  [
    { title: "Search API", url: "https://www.drupal.org/project/search_api" },
    {
      title: "Search API Pages",
      url: "https://www.drupal.org/project/search_api_page",
    },
    {
      title: "Search API Database Search",
      url: "https://www.drupal.org/project/search_api_db",
    },
    {
      title: "Patch",
      url: "https://www.drupal.org/files/issues/2489142-4--specific_host_entity_property.patch",
    },
  ]
date: 2016-04-03
node: 162
---

## Intro

This tutorial will assume that you are somewhat familiar with the [Search API](https://www.drupal.org/project/search_api) module. It also assumes you are using the [Search API](https://www.drupal.org/project/search_api) with the [Search API Database Search](https://www.drupal.org/project/search_api_db) and [Search API Pages](https://www.drupal.org/project/search_api_page) modules. The goal here is to ensure paragraph and field collection fields are being indexed by Search API and associated with their host node.

![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-03-at-3.13.13-PM.png)

> Above is the node we will be referencing. I kept the field labels visible on purpose so we can clearly distinguish between the paragraph and field collection fields.

![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-03-at-3.13.26-PM.png)

![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-03-at-3.13.44-PM.png)

> Above you can see that unique text from both fields has been indexed and is searchable.

## Add Paragraph and Field Collections Fields To Your Search Index

1. If you have the **Default node index** enabled (this comes by default with Search API) navigate to `admin/config/search/search_api/index/default_node_index/fields` and enable any paragraph or field collection fields. If not, simply create an index and make sure to include the content type that hosts your paragraph and field collection fields.

   ![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-03-at-2.53.42-PM.png)

2. Under **ADD RELATED FIELDS** find your paragraph and field collection fields and add them.

   1. For the field collection field, you will need to first add the field collection field. Once added, you will be able to relate the field collection to the content type it's associated with.

   ![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-03-at-2.54.19-PM.png)

   ![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-03-at-2.54.39-PM.png)

3. Once added, there will be additional fields available on the index page relating to your paragraph and field collection fields. Some of these fields are not helpful in a site search, such as the **Field collection item ID** or **Revision_id**. In my case, both my paragraph and field collections fields are long text fields, so I only enable the fields that pertain to the text field.

   ![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-03-at-3.02.17-PM.png)

   ![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-03-at-2.55.38-PM.png)

4. (Optional) Navigate to the **Filters** section of your search index and enable **Highlighting**. This is so you can see the specific string you searched highlighted on the results page.

   ![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-06-at-5.56.29-AM.png)

5. Navigate to the **View** tab of your search index. Make sure to index all of your data.

   ![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-06-at-6.00.22-AM.png)

6. Navigate to the Search API Search Page configuration page **admin/config/search/search_api/page**, and click **Edit** next to your search page.

7. Under **Searched fields** make sure to select the paragraph and field collection field we added earlier.

   ![](/assets/images/posts/configure-drupals-search-api-search-field-collections-and-paragraphs/Screen-Shot-2016-04-03-at-3.07.15-PM.png)

## Conclusion and Next Steps

This workflow can be applied to other fields as well. The key is to do the following:

1. Add the related field to the **index**.
   1. Add the related field to the host entity as demonstrated with field collection fields. This only needs to happened for fields such as field collection fields.
2. Add the newly added related field to the **Searched fields** under your search page configuration.
3. Re-index your data,

I have experienced issues [creating the relationship between a field collection and its host entity](https://www.drupal.org/node/2489142) when using Search API. If you run into this issue, try applying [this patch](https://www.drupal.org/files/issues/2489142-4--specific_host_entity_property.patch) to the field collection module.
