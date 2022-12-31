---
title: "Forestry CMS Blocks Field Demo"
categories: ["Web Development", "JAMstack"]
resources: [
    {
        title: "Source Code",
        url: "https://github.com/stevepolitodesign/forestry-cms-blocks-field-demo"
    },
    {
        title: "Front Matter Templates",
        url: "https://forestry.io/docs/settings/front-matter-templates/"
    },
    {
        title: "Forestry Blocks Field Documentation",
        url: "https://forestry.io/docs/settings/fields/blocks/"
    }
]
date: 2019-11-17
---

{% youtube "https://www.youtube.com/embed/TToomEilKs8" %}

Foresty CMS allows content editors to easily manage a staticly generated site without needing to know markdown or HTML. This works really well if you're just editing a page with a title and a body, but sometimes you need to offer more diversity. Luckily Forestry has a [Block Field](https://forestry.io/docs/settings/fields/blocks/) which allows a content editor to easily add robust content to a page. The example below shows how we can create a block field that displays highlights anywhere on a page.

![forestry block field example](/assets/images/posts/forestry-cms-blocks-field-demo/1.png)

## 0. Prerequisites

This tutorial assumes you have a site up and running on Forestry. I will be using Jekyll in this tutorial, but Forestry works with all major static site generators.

## 1. Create a New Front Matter Template to Be Used as a Block

In order to use a block field, you first need to create a [front matter template](https://forestry.io/docs/settings/front-matter-templates/).

> Front Matter Templates (FMTs) enable developers to fully customize the interface of the Markdown and HTML editors. You can think of them as the content model for your front matter.

1. Under the `Front matter` section on the sidebar, click `Add Template`, and select `blank template`.
![creating a new front matter template](/assets/images/posts/forestry-cms-blocks-field-demo/2.png)
2. Set the name to `Highlights` and select `Fields`.
![adding a new front matter field](/assets/images/posts/forestry-cms-blocks-field-demo/3.png)
3. On the next screen, click `Add Field` and select `Repeatable Field Group`
![selecting repeatable field group](/assets/images/posts/forestry-cms-blocks-field-demo/3a.png)
    1. Set the label to `Highlights`. Make sure the `name` is `highlights`.
    ![adding a repeatable field group label and name](/assets/images/posts/forestry-cms-blocks-field-demo/3aa.png)
    2. Set the `Minimum` value to `3` under the `Validation` tab.    
    ![adding validation to repeatable field group](/assets/images/posts/forestry-cms-blocks-field-demo/3aaa.png)
    3. Click `Add Field to "Highlights"`
    ![repeatable field group form](/assets/images/posts/forestry-cms-blocks-field-demo/3b.png)
    4. Select `Textfield`
    ![field options](/assets/images/posts/forestry-cms-blocks-field-demo/3c.png)    
    5. Set the `Label` to `Headline` and the `Name` to `headline`.
    ![field options](/assets/images/posts/forestry-cms-blocks-field-demo/3d.png)
    6. Enable`Required` under the `Validation` tab.    
    ![field validation options](/assets/images/posts/forestry-cms-blocks-field-demo/3e.png)
    7. Click `Add Field to "Highlights"` again.
    8. Select `Textfield`
    ![field options](/assets/images/posts/forestry-cms-blocks-field-demo/3f.png)
    9. Set the `Label` to `Description` and the `Name` to `description`.
    ![field options](/assets/images/posts/forestry-cms-blocks-field-demo/3g.png)
    10. Enable `Textarea/WYSIWYG` under the `Widget` tab.
    ![field options](/assets/images/posts/forestry-cms-blocks-field-demo/3h.png)
    11. Click `Add Field to "Highlights"` again.
    12. Select `Textfield`
    ![field options](/assets/images/posts/forestry-cms-blocks-field-demo/3f.png)
    13. Set the `Label` to `URL` and the `Name` to `url`.

The final configuration should look something like this:

![field options](/assets/images/posts/forestry-cms-blocks-field-demo/4.png)

## 2. Create a New Front Matter Template to Be Used as When Editing Pages

We now need to create a template for `Pages` on our site. This template will have a `Block` field that will contain the `Highlights` field we just created.

1. Under the `Front matter` section on the sidebar, click `Add Template`, and select `blank template`.
![creating a new front matter template](/assets/images/posts/forestry-cms-blocks-field-demo/2.png)
2. Set the name to `Page` and select `Fields and big content area`.
![creating a new front matter template](/assets/images/posts/forestry-cms-blocks-field-demo/5.png)
3. On the next screen, click `Add Field` and select `Blocks`
![selecting blocks field](/assets/images/posts/forestry-cms-blocks-field-demo/6.png)
        1. Set the label to `Page Sections`. Make sure the `name` is `page_sections`.
        ![adding a block field label and name](/assets/images/posts/forestry-cms-blocks-field-demo/7.png)
        2. Under the `Blocks` tab, select the `Highlights` we created in the previous steps.
        ![adding a front matter templates to block field](/assets/images/posts/forestry-cms-blocks-field-demo/8.png)
        
## 3. Assign The Page Template to Jekyll Pages

Now that we have a template that contains `Block` fields, we need to make this template available any `Page` on our site. 

1. Under the `Settings` section on the sidebar, navigate to the `Sidebar` tab, and click `Pages`.
2. Add the `Page` template we created in the previous steps to the `Available Templates` field.
![updating page template](/assets/images/posts/forestry-cms-blocks-field-demo/9.png)

## 5. Add Block Content To a Page, and Pull The Changes Locally.

Now all `Pages` in your site have a `Page Sections` field that allows you to add highlights. Go ahead and add some highlights to a page and save. 

![page with page sections](/assets/images/posts/forestry-cms-blocks-field-demo/10.png)

Once saved, run `git fetch; git pull` to pull in the new content and configuration.

Note that the page you edited should have a `page_sections:` key in the front matter with a list of nested `highlights:`. 

```yml{5}
# index.md
---
title: Forestry CMS Blocks Field Demo
description: This repository demonstrates how to use Forestry's Blocks Field to create
  rich layouts.
page_sections:
- template: highlights
  highlights:
  - headline: Free
    description: |-
      ## $0 / mo

      * 10 users included
      * 2 GB of storage
      * Email support
      * Help center access
    url: https://example.com
  - headline: Pro
    description: |-
      ## $15 / mo

      * 20 users included
      * 10 GB of storage
      * Priority email support
      * Help center access
    url: https://example.com
  - headline: Enterprise
    description: |-
      ## $29 / mo

      * 30 users included
      * 15 GB of storage
      * Phone and email support
      * Help center access
    url: https://example

---
# Forestry CMS Blocks Field Demo

This repository demonstrates how to use Forestry's [Blocks Field](https://forestry.io/docs/settings/fields/#blocks) to create rich layouts.
```

You'll also notice a `.forestry/front_matter/templates/highlights.yml` and `.forestry/front_matter/templates/page.yml` files. These were created by Foresty when we created our Front Matter templates. We could have created these files manually, but it's easier to make them with the Forestry GUI.

```yml
# .forestry/front_matter/templates/highlights.yml
---
label: Highlights
hide_body: true
fields:
- name: highlights
  type: field_group_list
  fields:
  - name: headline
    type: text
    config:
      required: true
    label: Headline
  - name: description
    type: textarea
    default: ''
    config:
      required: false
      wysiwyg: true
      schema:
        format: markdown
    label: Description
  - name: url
    type: text
    config:
      required: false
    label: URL
  config:
    min: '3'
    max: 
    labelField: 
  label: Highlights
```

```yml
# .forestry/front_matter/templates/page.yml
---
label: Page
hide_body: false
fields:
- name: title
  type: text
  config:
    required: true
  label: Title
- name: description
  type: textarea
  default: ''
  config:
    required: false
    wysiwyg: false
    schema:
      format: markdown
  label: Description
- name: page_sections
  type: blocks
  label: Page Sections
  template_types:
  - highlights
  config:
    min: 
    max: 
```

## 4. Display the Block Field Content

Now that we have our block field data stored in front matter, we need to have it displayed on the page. 

1. Add the following code to your layout.
    - This code loops through all items stored in the `page_sections` key on the front matter.
    - It then looks at what template that particular page section is using, and conditionally loads the corresponding partial.
    - We can DRY things up by using the template name in the name of the include by writing `include blocks_{{template}}.html` instead of `include blocks_highlights.html`

{% raw %}
```
    {% for block in page.page_sections %}
        {% assign template = block.template %}
        {% case template %}
        {% when 'highlights' %}
            {% include blocks_{{template}}.html %}        
        {% endcase %}
    {% endfor %} 
```

2. Create a `blocks_highlights.html` partial.
    - This is loaded via the `{% include blocks_{{template}}.html %}` line.

```
<div class="row mb-5">
    {% for highlight in block.highlights %}
        <div class="col-md-4">
            <h4>{{highlight.headline}}</h4>
            {{ highlight.description | markdownify}}
            {% if highlight.url %}
                <a href="{{highlight.url}}" class="btn btn-large btn-primary">Click Here</a>
            {% endif %}
        </div>
    {% endfor %}    
</div>
```
{% endraw %}
