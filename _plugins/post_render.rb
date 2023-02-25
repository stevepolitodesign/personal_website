require "./lib/jekyll-image-link"
require "./lib/jekyll-anchor-link"

Jekyll::Hooks.register [:documents], :post_render do |doc|
  Jekyll::ImageLink.new(doc).link_images
  Jekyll::AnchorLink.new(doc).link_headings
end
