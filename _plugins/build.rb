require "fileutils"
require "selenium-webdriver"
require "./lib/jekyll-screenshot"

Jekyll::Hooks.register :site, :after_init do |site|
  unless File.exist?(site.collections_path + "/node_modules")
    system("yarn")
  end
  if Jekyll.env == "test"
    site.config["collections"]["fixtures"]["output"] = true
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  unless Jekyll.env == "production"
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    driver = Selenium::WebDriver.for :chrome, options: options

    open_graph_pages = site.config["open_graph_pages"]
    destination_output = "_site/assets/images/open-graph"

    open_graph_pages.each do |open_graph_page|
      source_output = "assets/images#{open_graph_page.dir}"
      FileUtils.mkdir_p(source_output) unless Dir.exist?(source_output)
      open_graph_image = open_graph_page.source_document.data["og_image"]

      unless File.exist?(open_graph_image)
        Jekyll::Screenshot.new(
          driver,
          open_graph_page.file_path,
          "#open-graph",
          open_graph_image
        ).generate_screenshot_from_file
      end
    end

    FileUtils.remove_dir(destination_output) if Dir.exist?(destination_output)
    FileUtils.copy_entry("assets/images/open-graph", destination_output)

    driver.quit
  end
end
