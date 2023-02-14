---
title: Create a Bootstrap Starter Theme in Eleventy
categories: ["Web Development"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/eleventy-bootstrap-starter",
    },
    { title: "Parcel", url: "https://parceljs.org/" },
    { title: "Eleventy", url: "https://www.11ty.io/" },
  ]
date: 2019-10-05
---

With the rise in the [JAMStack](https://jamstack.org/) way of thinking, there has been a lot of development in static site generators. One that is quickly gaining popularity is [Eleventy](https://www.11ty.io/). Eleventy is very similar to [Jekyll](https://jekyllrb.com/), but compiles much faster because it's built on Node. What makes Eleventy stand out is its simplicity and flexibility.

> Eleventy was created to be a JavaScript alternative to Jekyll. It’s zero-config by default but has flexible configuration options. Eleventy works with your project’s existing directory structure.
>
> Eleventy uses independent template engines. We don’t want to hold your content hostage. If you decide to use something else later, having your content decoupled in this way will make migration easier

In this tutorial I'm going to show you how to quickly set up a boilerplate Eleventy theme using Bootstrap as our CSS framework and Parcel as our bundler. The goal of this tutorial isn't to build a fully themed website, but rather to create a simple boilerplate. The only assumption it makes is that you want to use Eleventy and Bootstrap.

Below is what we'll create.

![eleventy bootstrap starter theme](/assets/images/posts/create-a-bootstrap-starter-theme-in-eleventy/smoke-test.gif)

## 1. Initialize The Project and Install the Dependencies

1. Open up a new terminal window and run `npm init` in a new directory . Follow the prompts and enter your info. In my case I ran `npm init` in a directory named `eleventy-bootstrap-starter-demo`. I just used the default values.

   ```json
   {
     "name": "eleventy-bootstrap-starter-demo",
     "version": "1.0.0",
     "description": "",
     "main": "index.js",
     "scripts": {
       "test": "echo \"Error: no test specified\" && exit 1"
     },
     "author": "",
     "license": "ISC"
   }
   ```

2. Install development dependencies by running `npm i @11ty/eleventy npm-run-all -D`.
3. Install [Parcel](https://parceljs.org/) by running `npm install -g parcel-bundler`.

   - I chose Parcel because it's a **Blazing fast, zero configuration web application bundler**. Essentially, it will bundle and compile our `js` and `scss` by default.

4. Install project dependencies by running `npm i bootstrap jquery popper.js`

## 2. Create Header and Footer Partials and a Site Variables File

Now that we have our dependencies installed, we can start building out our boilerplate theme. A good place to start is the header and footer partials, since these will be shared across all page templates.

1. In the root of your project, run the follow commands to create a blank header and footer partial. Note that it's [Eleventy Convention](https://www.11ty.io/docs/layouts/) to put your partials in a `_includes` directory.

   - Note that I chose to use [Nunjucks](https://www.11ty.io/docs/languages/nunjucks/), but [Eleventy supports more template languages](https://www.11ty.io/docs/).

   ```sh
   mkdir _includes
   mkdir _includes/shared
   touch _includes/shared/footer.njk
   touch _includes/shared/header.njk
   ```

2. Create a data file to store site variables at ` _data/site.json` by running the following commands. Note that it's [Eleventy Convention](https://www.11ty.io/docs/data-js/) to store site variables in a `_data` directory. In our case we're adding default `title` and `description` values to be loaded in the meta data of our site.

```sh
mkdir _data
touch _data/site.json
```

```json
{
  "title": "Add the title of your website here. This is used in the <title></title>",
  "description": "Add your site description here. This is used in <meta name='description' content=''>"
}
```

## 3. Import Bootstrap

Now that we have a base, we can import Bootstrap as our framework of choice. Since we will be using Parcel as our bundler, we're going to follow [Parcel's Bootstrap recipe](https://parceljs.org/recipes.html#importing-bootstrap-with-precompiled-styles).

1. In order to keep our assets organized, run the following commands in the root of your project to create the correct file structure.

   ```sh
   mkdir _assets
   mkdir _assets/css
   mkdir _assets/css/vendor
   touch _assets/css/vendor/_bootstrap.scss
   ```

2. Add the following to `_assets/css/vendor/_bootstrap.scss`

   ```scss
   @import "./../../../node_modules/bootstrap/scss/bootstrap.scss";
   ```

3. In order to override Bootstrap's default variables, run the following commands in the root of your project to create a `_bootstrap_overrides.scss` file. This is where you can override the default variables.

   ```sh
   mkdir _assets/css/base
   touch _assets/css/base/_bootstrap_overrides.scss
   ```

4. As a note, I added the following to `_assets/css/base/_bootstrap_overrides.scss`

   ```scss
   // Override Bootstraps Variables Here
   // Reference node_modules/bootstrap/scss/_variables.scss for a full list of variables
   // https://getbootstrap.com/docs/4.3/getting-started/theming/#variable-defaults
   ```

5. Now that we have Bootstrap and our custom overrides file created, open up `_assets/css/main.scss` and import the files.

   ```scss
   // Bootstrap Overrides
   @import "./base/bootstrap_overrides";

   // Bootstrap
   @import "./vendor/bootstrap";
   ```

6. In order to load Bootstrap's [Popovers](https://getbootstrap.com/docs/4.3/components/popovers/) and [Tooltips](https://getbootstrap.com/docs/4.3/components/tooltips/) dependencies, run the following commands in the root of your project.

   ```sh
   mkdir _assets/js
   mkdir _assets/js/vendor
   touch _assets/js/vendor/popover.js
   touch _assets/js/vendor/tooltip.js
   touch _assets/css/main.scss
   ```

7. Open `_assets/js/vendor/popover.js` and add the following. This [enables popovers everywhere](https://getbootstrap.com/docs/4.3/components/popovers/#example-enable-popovers-everywhere).

   ```js
   import $ from "jquery";

   $(function () {
     $('[data-toggle="popover"]').popover();
   });
   ```

8. Open `_assets/js/vendor/tooltip.js` and add the following. This [enables tooltips everywhere](https://getbootstrap.com/docs/4.3/components/tooltips/#example-enable-tooltips-everywhere).

   ```js
   import $ from "jquery";

   $(function () {
     $('[data-toggle="tooltip"]').tooltip();
   });
   ```

9. Now we need to import all of our `js` and `scss` in to one file for Parcel to bundle. In the root of your project run `touch _assets/js/main.js` and add the following to the file.

   ```js
   // Bootstrap JS and CSS
   import "bootstrap";
   import "./../css/main.scss";

   // Bootstrap Popover
   import "./vendor/popover";

   // Bootstrap Tooltip
   import "./vendor/tooltip";
   ```

10. Now that we have a file for Parcel to bundle, we need to load that file into our project. Open up `_includes/shared/footer.njk` we created earlier and add the following:

    - I am getting this from [Parcel's Bootsrap Recipe.](https://parceljs.org/recipes.html#importing-bootstrap-with-precompiled-styles)

    ```html
    <script src="./assets/main.js"></script>
    </body>
    </html>
    ```

11. Open up `_includes/shared/header.njk` we created earlier and add the following:

    - We dynamically load the `<title>` and `<meta name="description">` based on `_data/site.json`
    - We load the css via `<link rel="stylesheet" href="./assets/main.css">` which will eventually be generated by Parcel.

    ```html
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="ie=edge" />
        {% if title %}
        <title>{{site.title}} - {{title}}</title>
        {% else %}
        <title>{{site.title}}</title>
        {% endif %} {% if description %}
        <meta name="description" content="{{description}}" />
        {% else %}
        <meta name="description" content="{{site.description}}" />
        {% endif %}
        <link rel="stylesheet" href="./assets/main.css" />
      </head>
      <body></body>
    </html>
    ```

## 4. Create default layout

Now that we have everything wired up, we can create a default layout to use throughout our theme.

1. In the root of your project, run the follow commands.

   ```sh
   mkdir _includes/layouts
   touch _includes/layouts/default.njk
   ```

2. Open `_includes/layouts/default.njk` and add the following:

{% raw %}

    ```sh
    {% include "shared/header.njk" %}
    {{ content | safe }}
    {% include "shared/footer.njk" %}
    ```

    - `{% include ... %}` is a [supported template feature](https://www.11ty.io/docs/languages/nunjucks/#supported-features) of Nunjucks. This is how we include `shared/header.njk` and `shared/footer.njk` in the layout.
    - `{{ content | safe }}` allows us to load [escaped layouts](https://www.11ty.io/docs/layouts/#prevent-double-escaping-in-layouts).

{% endraw %}

3. Create a [layout alias](https://www.11ty.io/docs/layouts/#layout-aliasing) by running `touch .eleventy.js`. Open `touch .eleventy.js` and add the following:

   ```js
   module.exports = function (eleventyConfig) {
     eleventyConfig.addLayoutAlias("default", "layouts/default.njk");
   };
   ```

4. Create an index page by running `touch index.njk` and adding the following:

   ```yml
   ---
   layout: default
   title: Custom Title
   description: Custom Description
   ---
   ```

   - We can write `layout: default` because we created a layout alias in `.eleventy.js`.

## 5. Add Production and Development npm Scripts

Now that we have all of our files created, we need to tell our project how to compile. Since Eleventy and Parcel are two separate and independent command lines tools, we can use [npm-run-all](https://www.npmjs.com/package/npm-run-all) to run them in parallel.

1. Open `package.json` and add update the `scripts` section.

```json
"scripts": {
"start": "npm-run-all --parallel dev:_",
"build": "run-s prod:_",
"dev:eleventy": "eleventy --serve",
"dev:parcel": "parcel watch ./_assets/js/main.js --out-dir ./_site/assets",
"prod:eleventy": "eleventy",
"prod:parcel": "parcel build ./_assets/js/main.js --out-dir ./_site/assets"
},
```

- `"dev:eleventy": "eleventy --serve"`
  - [Re-run Eleventy as you save](https://www.11ty.io/docs/usage/#re-run-eleventy-when-you-save).
- `dev:parcel": "parcel watch ./_assets/js/main.js --out-dir ./_site/assets"`
  - `watch ./_assets/js/main.js` watches the entry point.
  - `--out-dir ./_site/assets`
    - We need to put the compiled assets in the `_site/` directory created be Eleventy. Otherwise it will just compile to a `dist/` directory which Eleventy doesn't know about. [More information on --out-dir can be found here](https://parceljs.org/cli.html#output-directory).
- `"prod:eleventy": "eleventy"`
  - Builds the Eleventy site.
- `"prod:parcel": "parcel build ./_assets/js/main.js --out-dir ./_site/assets"`
  - Minifies scripts and styles and places them in the `_site/` directory create be Eleventy.
- `"start": "npm-run-all --parallel dev:*"` runs all scripts that start with `dev:`
- `"build": "run-s prod:*"` runs all scripts that start with `prod:`

## 6. Ignore Specific Files and Folders Generated by Eleventy, Parcel and npm

1. In the root of your project, run `touch .gitignore`. Open `.gitignore` and add the following to ignore files and folders generated by Eleventy, Parcel and npm

```sh
node_modules
.cache
_site
```

## 7. Load Test Elements on the Page To Ensure Everything Is Working Correctly

1. Open `index.njx` and add the following:

   ```html
   <div class="bd-example">
     <div class="p-3 mb-2 bg-primary text-white">.bg-primary</div>
     <div class="p-3 mb-2 bg-secondary text-white">.bg-secondary</div>
     <div class="p-3 mb-2 bg-success text-white">.bg-success</div>
     <div class="p-3 mb-2 bg-danger text-white">.bg-danger</div>
     <div class="p-3 mb-2 bg-warning text-dark">.bg-warning</div>
     <div class="p-3 mb-2 bg-info text-white">.bg-info</div>
     <div class="p-3 mb-2 bg-light text-dark">.bg-light</div>
     <div class="p-3 mb-2 bg-dark text-white">.bg-dark</div>
     <div class="p-3 mb-2 bg-white text-dark">.bg-white</div>
     <div class="p-3 mb-2 bg-transparent text-dark">.bg-transparent</div>
   </div>

   <!-- Button trigger modal -->
   <button
     type="button"
     class="btn btn-primary"
     data-toggle="modal"
     data-target="#exampleModal"
   >
     Launch demo modal
   </button>

   <!-- Modal -->
   <div
     class="modal fade"
     id="exampleModal"
     tabindex="-1"
     role="dialog"
     aria-labelledby="exampleModalLabel"
     aria-hidden="true"
   >
     <div class="modal-dialog" role="document">
       <div class="modal-content">
         <div class="modal-header">
           <h5 class="modal-title" id="exampleModalLabel">Modal title</h5>
           <button
             type="button"
             class="close"
             data-dismiss="modal"
             aria-label="Close"
           >
             <span aria-hidden="true">&times;</span>
           </button>
         </div>
         <div class="modal-body">...</div>
         <div class="modal-footer">
           <button type="button" class="btn btn-secondary" data-dismiss="modal">
             Close
           </button>
           <button type="button" class="btn btn-primary">Save changes</button>
         </div>
       </div>
     </div>
   </div>

   <button
     type="button"
     class="btn btn-lg btn-danger"
     data-toggle="popover"
     title="Popover title"
     data-content="And here's some amazing content. It's very engaging. Right?"
   >
     Click to toggle popover
   </button>

   <button
     type="button"
     class="btn btn-secondary"
     data-toggle="tooltip"
     data-placement="top"
     title="Tooltip on top"
   >
     Tooltip on top
   </button>
   <button
     type="button"
     class="btn btn-secondary"
     data-toggle="tooltip"
     data-placement="right"
     title="Tooltip on right"
   >
     Tooltip on right
   </button>
   <button
     type="button"
     class="btn btn-secondary"
     data-toggle="tooltip"
     data-placement="bottom"
     title="Tooltip on bottom"
   >
     Tooltip on bottom
   </button>
   <button
     type="button"
     class="btn btn-secondary"
     data-toggle="tooltip"
     data-placement="left"
     title="Tooltip on left"
   >
     Tooltip on left
   </button>
   ```

2. Make sure the modal, tooltips and popovers work.

   ![eleventy bootstrap starter theme](/assets/images/posts/create-a-bootstrap-starter-theme-in-eleventy/smoke-test.gif)

## Conclusion and Next Steps

Now you can override Bootstrap's variables in `_assets/css/base/_bootstrap_overrides.scss` to create a more customized theme. I've found that by doing this and using [Utilities](https://getbootstrap.com/docs/4.3/extend/approach/#utilities) you can create custom and unique layouts that don't resemble Bootstrap.
