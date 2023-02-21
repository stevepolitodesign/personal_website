---
layout: default
title: "Contact Steve Polito"
excerpt: "Email me at stevepolito@hey.com"
---

Want to get in touch? Email me at <a href="mailto:stevepolito@hey.com">stevepolito@hey.com</a> or fill out the form
below.

You can also find me on [Twitter][] and [GitHub][].

<form name="contact" data-netlify="true" method="POST" action="/thanks/" class="vstack gap-4">
  <div class="row">
    <div class="col-auto">
      <label for="name" class="form-label">Name</label>
      <input type="text" id="name" name="name" class="form-control">
    </div>
    <div class="col-auto">
      <label for="email" class="form-label">Email</label>
      <input type="email" id="email" name="email" class="form-control" required>
      <div class="form-text">Required</div>
    </div>
  </div>
  <div class="row">
    <div>
      <label for="message" class="form-label">Message</label>
      <textarea id="message" name="message" class="form-control" required></textarea>
      <div class="form-text">Required</div>
    </div>
  </div>
  <div class="row">
    <div class="col-auto">
      <button type="submit" class="btn btn-primary">Send</button>
    </div>
  </div>
</form>

[twitter]: https://twitter.com/stevepolitodsgn
[github]: https://github.com/stevepolitodesign
