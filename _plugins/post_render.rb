require "./lib/jekyll_image_link"
require "./lib/jekyll_anchor_link"

Jekyll::Hooks.register [:documents], :post_render do |doc|
  Jekyll::ImageLink.new(doc).link_images
  Jekyll::AnchorLink.new(doc).link_headings
end
