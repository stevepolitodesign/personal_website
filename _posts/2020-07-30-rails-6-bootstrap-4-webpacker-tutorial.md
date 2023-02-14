---
title: Install Bootstrap 4 on a Rails 6 App with Webpacker
categories: ["Ruby on Rails"]
resources:
  [
    {
      title: "Source Code",
      url: "https://github.com/stevepolitodesign/rails-6-bootstrap-4-integration",
    },
    {
      title: "GoRails Example",
      url: "https://gorails.com/episodes/how-to-use-bootstrap-with-webpack-and-rails",
    },
    {
      title: "Add Webpack Plugins",
      url: "https://github.com/rails/webpacker/blob/749675d9c035dbc8777f718582e3e4804147e9e5/docs/webpack.md#plugins",
    },
    {
      title: "stylesheet_pack_tag",
      url: "https://github.com/rails/webpacker/blob/bf278f9787704ed0f78038ad7d36c008abc2edfd/docs/css.md#link-styles-from-your-rails-views",
    },
  ]
date: 2020-07-30
---

I know many existing tutorials explain how to install Bootstrap 4 on a Rails 6 application with Webpacker (like the [GoRails example](https://gorails.com/episodes/how-to-use-bootstrap-with-webpack-and-rails)). However, I wanted to create this tutorial to highlight a few gotchas, as well as highlight _why_ and _how_ I made some of my choices.

1. `rails new rails-bootstrap`
2. `yarn add bootstrap jquery popper.js`
3. Add jQuery and Popper.js plugins. These are [required](https://getbootstrap.com/docs/4.5/getting-started/introduction/#js) by Bootstrap.

   > This step was always so cryptic to me. I would just blindly copy and paste what I saw on other tutorials, but I wanted to know _how_ people knew to even do this.

   I found [this example](https://github.com/rails/webpacker/blob/749675d9c035dbc8777f718582e3e4804147e9e5/docs/webpack.md#plugins) in the Webpacker docs, so decided to use it knowing it was in the official documentation.

   ```js
   // config/webpack/environment.js
   const { environment } = require("@rails/webpacker");
   const webpack = require("webpack");

   environment.plugins.prepend(
     "Provide",
     new webpack.ProvidePlugin({
       $: "jquery",
       jQuery: "jquery",
       jquery: "jquery",
       "window.jQuery": "jquery",
       Popper: ["popper.js", "default"],
     })
   );

   module.exports = environment;
   ```

   > Another big problem I ran into was how to correctly import Bootstrap's styles.

   I initially created `app/javascript/packs/application.scss` and imported the styles in that file. However, that seemed to break my build in a way that made it so `app/javascript/packs/application.js` never compiled.

   Next, I renamed `app/assets/stylesheets/application.css` to `app/assets/stylesheets/application.scss`, and imported the styles into that file. That worked, but it meant that the Asset Pipeline was responsible for my styles. This isn't necessarily a bad thing, but I wanted Webpacker to be responsible for all of my front-end code.

   Also, by using a `.scss` file, you can easily [override Bootstrap's default variales](https://getbootstrap.com/docs/4.5/getting-started/theming/#variable-defaults)

4. `mkdir app/javascript/`
5. `touch app/javascript/stylesheets/application.scss`
6. Import Bootstrap Styles

   ```scss
   // app/javascript/stylesheets/application.scss
   @import "~bootstrap/scss/bootstrap";
   ```

7. Import Bootstrap, load styles, and optionally load [Tooltips](https://getbootstrap.com/docs/4.5/components/tooltips/#example-enable-tooltips-everywhere) and [Popovers](https://getbootstrap.com/docs/4.5/components/popovers/#example-enable-popovers-everywhere) everywhere.

   ```js
   // app/javascript/packs/application.js

   require("bootstrap");
   import "../stylesheets/application";
   document.addEventListener("turbolinks:load", function () {
     $(function () {
       $('[data-toggle="tooltip"]').tooltip();
       $('[data-toggle="popover"]').popover();
     });
   });
   ```

   > Webpacker emits css files only if `extract_css` is set to `true` in `webpacker.yml` otherwise `stylesheet_pack_tag` returns nil.

   When I was running through these steps, I found it strange that I didn't need to add a [stylesheet_pack_tag](https://github.com/rails/webpacker/blob/bf278f9787704ed0f78038ad7d36c008abc2edfd/docs/css.md#link-styles-from-your-rails-views) as I had seen in other tutorials. I realized that this is because I was in development.

   If you change `extract_css: false` to `extract_css: true` under the `default:` block in `config/webpacker.yml` and then restart your server, you'll notice that the styles no longer load.

8. To fix this, simply add the `stylesheet_pack_tag` and restart the server. After ensuring the styles haves loaded set `extract_css: true` back to `extract_css: false` under the `default:` block in `config/webpacker.yml`. You might need to run `rails webpacker:clobber` after making that change.

   ```erb
   <%# app/views/layouts/application.html.erb %>

   <!DOCTYPE html>
   <html>
     <head>
       <title>RailsBootstrap4Integration</title>
       <%= csrf_meta_tags %>
       <%= csp_meta_tag %>

       <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
       <%# ℹ️ Add stylesheet_pack_tag %>
       <%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
       <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
     </head>

     <body>
       <div class="container">
         <%= yield %>
       </div>
     </body>
   </html>

   ```

9. Finally, add the [responsive meta tag](https://getbootstrap.com/docs/4.5/getting-started/introduction/#responsive-meta-tag)

   ```erb
   <%# app/views/layouts/application.html.erb %>

   <!DOCTYPE html>
   <html>
     <head>
       <title>RailsBootstrap4Integration</title>
       <%= csrf_meta_tags %>
       <%= csp_meta_tag %>
       <%# ℹ️ Add a responsive meta tag %>
       <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

       <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
       <%= stylesheet_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
       <%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
     </head>

     <body>
       <div class="container">
         <%= yield %>
       </div>
     </body>
   </html>
   ```
