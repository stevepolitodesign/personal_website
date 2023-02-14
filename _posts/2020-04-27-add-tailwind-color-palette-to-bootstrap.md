---
title: "Add Tailwind CSS Color Palette to Bootstrap"
categories: ["Web Development"]
resources:
  [
    {
      title: "tailwind-color-palette package",
      url: "https://github.com/stevepolitodesign/tailwind-color-palette",
    },
    { title: "Demo", url: "https://tailwind-color-palette-demo.netlify.app/" },
  ]
date: 2020-04-27
---

You might be wondering why anyone would want to add [Tailwind's default color palette](https://tailwindcss.com/docs/customizing-colors/#default-color-palette) to Bootstrap. It comes down to personal preference, but below are the key reasons I think this is beneficial.

## Why adding the Tailwind color palette to Bootstrap is beneficial:

1. Tailwind is **only** a CSS framework. It doesn't come with battle tested, commonly used JavaScript components like [modals](https://getbootstrap.com/docs/4.4/components/modal/) or [tabs](https://getbootstrap.com/docs/4.4/components/collapse/).
   1. I know [TailwindUI](https://tailwindui.com/) ships with a lot of components, but this **does not** include JavaScript. More importantly, Bootstrap has already accounted for edge cases and accessibility. Why reinvent the wheel?
1. Bootstrap ships with [base styles](https://getbootstrap.com/docs/4.4/content/reboot/#page-defaults), whereas [Tailwind](https://tailwindcss.com/docs/adding-base-styles) does not.
1. Bootstrap already ships with [utility classes](https://getbootstrap.com/docs/4.4/extend/approach/#utilities).
1. Bootstrap's [color palette](https://getbootstrap.com/docs/4.4/utilities/colors/) is very limited, whereas [Tailwind's color palette](https://tailwindcss.com/docs/customizing-colors/#default-color-palette) is extensive.

## How to extend Bootstrap by adding the Tailwind color palette

{% youtube "https://www.youtube.com/embed/0J_e_7QQ-uU" %}

1. [Import](https://getbootstrap.com/docs/4.4/getting-started/theming/#variable-defaults) Bootstrap and its default variables.

   ```scss
   // some-file.scss
   @import "~bootstrap/scss/bootstrap";
   ```

2. Run `npm i tailwind-color-palette` or `yarn add tailwind-color-palette`.
3. Import tailwind-color-palette.

   ```scss
   // some-file.scss
   // ℹ️ Import the file
   @import "~tailwind-color-palette/scss/tailwind-color-palette";
   @import "~bootstrap/scss/bootstrap";
   ```

   Now you have access to [background color utility classes](https://github.com/stevepolitodesign/tailwind-color-palette#background-color-utility-class-structure) and [text color utility classes](https://github.com/stevepolitodesign/tailwind-color-palette#text-color-utility-class-structure).

4. Optionally override [Bootstrap's variables](https://github.com/twbs/bootstrap/blob/master/scss/_variables.scss).

   ```scss
   // some-file.scss
   @import "~tailwind-color-palette/scss/tailwind-color-palette";
   // ℹ️ Optionally override Bootstrap's variables
   $primary: map-get($tw_indigo, 900);
   @import "~bootstrap/scss/bootstrap";
   ```
