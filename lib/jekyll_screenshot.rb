module Jekyll
  class Screenshot
    def initialize(driver, path, selector, destination)
      @driver = driver
      @path = path
      @selector = selector
      @destination = destination
    end

    def generate_screenshot_from_file
      driver.get(path)
      allow_google_fonts_to_load
      element = driver.find_element(:css, selector)
      screenshot = element.screenshot_as(:png)
      File.binwrite(destination, screenshot)
    end

    private

    attr_reader :driver, :path, :selector, :destination

    def allow_google_fonts_to_load
      sleep 1
    end
  end
end
