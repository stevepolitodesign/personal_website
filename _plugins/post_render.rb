require "./lib/jekyll-image-link"

Jekyll::Hooks.register [:documents], :post_render do |doc|
  Jekyll::ImageLink.new(doc).link_images
end
