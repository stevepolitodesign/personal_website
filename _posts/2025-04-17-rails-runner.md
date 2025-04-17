---
title: Faster feedback loops with Rails Runner
excerpt: Don't waste one more second coding in the Rails console.
category: ["Ruby on Rails"]
canonical_url: https://thoughtbot.com/blog/rails-runner
---

I recently needed to explore how best to craft and parse a series of network
requests as part of a feature I was working on.

It didn't make sense to write a test for this, since I was only exploring the
idea, and because our test suite is configured to prevent making HTTP requests.

Because of this, I first tried to do all the work in the Rails console, but
found it to be too cumbersome. Then I decided to use the [rails runner][runner]
with a temporary file located at `lib/scratchpad.rb`.

```ruby
# lib/scratchpad.rb

# Explore how to craft network request
# Parse response
# Process response
```

Now that I was back in a proper developer environment, I could leverage all the
[debugging][] tools that ship with Rails. The end result was that I created a
fast feedback loop that allowed me to explore the idea more effectively.

When I was done, I knew how to build my requests, and was able to re-use that
code for both the implementation and for stubbing out the requests and responses
in my tests.

## Tighten the loop

Since I found this process so valuable, I decided to make it part of my Rails
workflow moving forward.

If you're using Vim, or any editor that supports custom key mappings, you could
make a mapping to `bin/rails runner lib/scratchpad.rb`. 

```
" ~/.vimrc

" Rails Scratchpad
nnoremap <silent> <Leader>xx :!bin/rails runner lib/scratchpad.rb<CR>
```

Then you can configure Git to ignore this file globally.

```
# ~/.gitignore

lib/scratchpad.rb
```

Now executing this file is no different than executing my tests.

## Next steps

This approach doesn't have to be limited to exploring network requests. Since the
file has access to the entire Rails application, you could use it to explore new
Jobs, Models, Services, and more. This concept was largely inspired by Kasper
Timm Hansen's [Riffing on Rails][riffing] approach.

[runner]: https://guides.rubyonrails.org/command_line.html#bin-rails-runner
[debugging]: https://guides.rubyonrails.org/debugging_rails_applications.html
[riffing]: https://github.com/kaspth/riffing-on-rails
