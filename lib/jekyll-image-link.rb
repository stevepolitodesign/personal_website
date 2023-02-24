require "nokogiri"

module Jekyll
  class ImageLink
    def initialize(jekyll_document)
      @jekyll_document = jekyll_document
    end

    def link_images
      content = @jekyll_document.output
      doc = Nokogiri::HTML(content)

      doc.css("main img").each do |img|
        unless img.parent.name == "a"
          src = img.attr("src")
          img.wrap("<a href='#{src}'></a>")
          img.parent.add_class("border d-block text-center")
          img.add_next_sibling("<span>Click to expand</span>")
          img.next_sibling.add_class("d-inline-block py-3")
        end
      end

      jekyll_document.output = doc.to_html
    end

    private

    attr_accessor :jekyll_document
  end
end
