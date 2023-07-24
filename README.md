# 🤓 Steve Polito's Personal Site

[![CI](https://github.com/stevepolitodesign/personal_website/actions/workflows/ci.yml/badge.svg)](https://github.com/stevepolitodesign/personal_website/actions/workflows/ci.yml)

## 🚀 Set Up

```sh
bundle install
```

## 🛠 Local Development

```sh
bundle exec jekyll serve --livereload
```

## ✍️ Content Creation

### 📸 Open Graph Images

Open Graph images are automatically created for every page on the site. This
only works in a non-production environment since this task depends on Selenium
being installed. The content used for the Open Graph images is based on the
title of the page.

#### Additional Details

- [Create class to take screenshots][1]
- [Generate open graph images from page titles][2]

### 🔗 Linking to External Posts

Sometimes I write for other blogs, but I want to share my work on my personal
website. In theses cases I simply add a `canonical_url` key to the front matter
of a blank post.

```yml
---
title: "Some title"
canonical_url: https://external.com/blog/example.html
---
```

#### Additional Details

- [Support rendering posts from other websites][3]

## ✅ Tests and CI

### Test Suite

```sh
bundle exec rake
```

### CI

GitHub actions runs CI which runs the test suite and standard.

## 🧼 Linting

### Prettier

Run `npx prettier --write path/to/file` to lint a specific file or files if
using glob pattern matching.

There's also a pre-commit hook via `./husky/pre-commit` that will lint any files
that were just committed.

### Standard

Run `bundle exec standardrb --fix` to fix any Ruby violations. This is currently
run as part of CI.

### Markdown

Run `./bin.mdl path/to/markdown/file` to lint a specific file or files if using
glob pattern matching. Since the existing posts were migrating from a previous
Gatsby build, there are a lot of violations. This is better suited for new
posts, and as such, is not part of CI.

## Issues

### ChromeDriver

The following error can be resolved by running `brew upgrade chromedriver`

```
4248000: session not created: This version of ChromeDriver only supports Chrome
version 110 (Selenium::WebDriver::Error::SessionNotCreatedError)
Current browser version is 115.0.5790.102 with binary path /Applications/Google
Chrome.app/Contents/MacOS/Google Chrome
```

[1]: https://github.com/stevepolitodesign/personal_website/commit/9d07b67204edbade29e6107da865905e6a504a13
[2]: https://github.com/stevepolitodesign/personal_website/commit/4f8fa9cac62ae8c374d92cdbf21805eeef4da6d9
[3]: https://github.com/stevepolitodesign/personal_website/commit/c7d43db794c9ef95e9c69a7127df438d296d3c8f
