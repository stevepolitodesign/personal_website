module Jekyll
  class OpenGraphPageGenerator < Jekyll::Generator
    def generate(site)
      open_graph_pages = []
      styles = build_styles
      documents = build_documents(site)
      open_graph_page_params = {site: site, styles: styles}

      documents.each do |document|
        case document_type(document)
        when :post
          open_graph_page_params.merge!(
            source_document: document,
            title: document.data["title"],
            dir: "open-graph/blog",
            basename: document.data["slug"],
            image_path: "blog/#{document.data["slug"]}"
          )

          build_open_graph_page(open_graph_page_params, open_graph_pages)
        when :page
          open_graph_page_params.merge!(
            source_document: document,
            title: document.data["title"],
            dir: "open-graph#{document.dir}",
            basename: document.basename,
            image_path: document.basename
          )

          build_open_graph_page(open_graph_page_params, open_graph_pages)
        when :archive
          open_graph_page_params.merge!(
            source_document: document,
            title: "Latest #{document.title} posts from Steve Polito",
            dir: "open-graph/#{document.type}",
            basename: document.slug,
            image_path: "#{document.type}/#{document.slug}"
          )

          build_open_graph_page(open_graph_page_params, open_graph_pages)
        end
      end

      site.pages.concat(open_graph_pages) unless ENV["JEKYLL_ENV"] == "production"
      site.config["open_graph_pages"] = open_graph_pages
    end

    private

    def build_styles
      scss_contents = File.read("assets/css/main.scss").delete!("---")
      converter = Jekyll::Converters::Scss.new({})

      converter.convert(scss_contents)
    end

    def build_documents(site)
      site.pages.concat + site.posts.docs
    end

    def document_type(document)
      if document.instance_of?(Jekyll::Document) && document.type == :posts
        :post
      elsif document.instance_of?(Jekyll::Archives::Archive)
        :archive
      elsif document.instance_of?(Jekyll::Page) && document.ext == ".md"
        :page
      end
    end

    def build_open_graph_page(params, open_graph_pages)
      open_graph_page = OpenGraphPage.new(**params)
      open_graph_page.add_og_image_to_source_document
      open_graph_pages << open_graph_page
    end
  end

  class OpenGraphPage < Jekyll::Page
    attr_reader :source_document, :file_path, :image_path

    def initialize(site:, source_document:, title:, styles:, dir:, basename:, image_path:)
      @site = site
      @base = site.source
      @dir = dir

      @basename = basename
      @ext = ".html"
      @name = "#{@basename}.html"

      @source_document = source_document
      @file_path = "file://#{site.config["destination"]}/#{@dir}/#{@name}"
      @title = title
      @styles = styles
      @image_path = image_path

      @data = {
        "layout" => "open-graph",
        "title" => @title,
        "styles" => @styles,
        "sitemap" => false
      }
    end

    def add_og_image_to_source_document
      source_document.data["og_image"] = "assets/images/open-graph/#{image_path}.png"
    end
  end
end
