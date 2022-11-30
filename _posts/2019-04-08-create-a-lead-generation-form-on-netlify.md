---
title: Create a Lead Generation Form on Netlify
categories: ["Netlify"]
resources: [
    {
        title: "Repo",
        url: "https://github.com/stevepolitodesign/client-side-authorization"
    },
    {
        title: "Demo Site",
        url: "https://client-side-authorization.netlify.com/"
    },
    {
        title: "Netlify Form API",
        url: "https://www.netlify.com/docs/form-handling/"
    },
    {
        title: "Netlify AJAX Form Submissions",
        url: "https://www.netlify.com/docs/form-handling/#ajax-form-submissions"
    }
]
date: 2019-04-08
---

I recently needed to help a client create lead generation forms on their website. The website was already in development, and was completely static. Because the site was static, I recommended they host with Netlify. I also made this recommendation because Netlify can store form submissions.

However, the challenge was to ensure a user could not easily bypass the form to access the private content if they knew the right URLs. I know that Netlify offers [Authentication](https://www.netlify.com/docs/identity/), but I felt that this was overkill for the project. The client simply wanted to grant users access to content in return for their contact info.

I ended up writing a custom [class declaration](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes) that would whitelist the requested url when a user filled out the form. I wrote another class declaration that checks to see if the url requested has been whitelisted. If so, the user can view the requested page. If not, they are redirected to the form.

![demo](/assets/images/posts/create-a-lead-generation-form-on-netlify/demo.gif)

You can view my [repository here](https://github.com/stevepolitodesign/client-side-authorization), or keep reading to get a detailed explanation.

## Use Cases

This solution should only be used if your project meets the following criteria:

1. Your site is hosted at [Netlify](https://www.netlify.com/)
1. Your website is static, and is only client-side
1. You want collect leads
1. You want to ensure the private page can't be easily accessed by bypassing the form
1. The data on the private page is not sensitive

## Important Notes

- Everything is client-side
- There is no authentication
- "Authorization" is handled through [localStorage](https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage)
- You'll want to add a `robots.txt` file and `Disallow` all private pages. This will help ensure the data won't be crawled and exposed on search engines

## Hijack the Form

The code below does the following when a user submits the form:

1. Prevents the form from submitting by default.
1. Checks to see if the form's `action` has been whitelisted.
1. If it hasn't been whitelisted, it will push the url to a whitelist `array` in `localstorage`
1. Redirects to the form's `action`.

```js
class formRedirect {
    constructor(form){
        this.form = document.querySelector(form);
        this.url = this.form.action;
        this.handleSubmit();
    }

    handleSubmit() {
        if (!this.url || !this.form) { return }

        this.form.addEventListener('submit', (e) => {
            e.preventDefault();
            this.whiteListURL(this.url);
            
            // https://www.netlify.com/docs/form-handling/#ajax-form-submissions
            var $form = $(this.form);
            $.post($form.attr("action"), $form.serialize()).then(function() {
                window.location = this.url;
            });

        });
    }

    whiteListURL(url) {
        if(!url) { return; }

        let urls = this.getWhiteListURLs();

        if ( urls.indexOf(url) === -1 ) {
            urls.push(url);
            localStorage.setItem('whiteListedUrls', JSON.stringify(urls));
        }
        
    }

    getWhiteListURLs() {
        return localStorage.getItem('whiteListedUrls') ? JSON.parse(localStorage.getItem('whiteListedUrls')) : [];
    }

}
```

## Prevent User from Bypassing Form

The code below ensures a user can't access the private page if they happen to know the URL.

```js
class privatePage {
    constructor(redirectUrl = '/', message = 'You are not authorized to view this page') {
        this.redirectUrl = redirectUrl;
        this.message = message;
        this.url = window.location.href;
        this.handlePageLoad();
    }

    handlePageLoad() {
        let urls = this.getWhiteListURLs();
        if ( urls.indexOf(this.url) === -1 ) {
            alert(this.message);
            window.location =  this.redirectUrl;
        }
    }

    getWhiteListURLs() {
        return localStorage.getItem('whiteListedUrls') ? JSON.parse(localStorage.getItem('whiteListedUrls')) : [];
    }
}
```