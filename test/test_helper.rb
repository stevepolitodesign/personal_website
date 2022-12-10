require "minitest/autorun"
require "minitest/hooks/test"
require "minitest/rg"
require "capybara/minitest"
require "rack/jekyll"

Capybara.app = Rack::Jekyll.new(fource_build: true)

module Minitest::Assertions
  def assert_exist(filename, msg = nil)
    msg = message(msg) { "Expected '#{filename}' to exist" }
    assert_path_exists("_site/#{filename}", msg)
  end

  def refute_exist(filename, msg = nil)
    msg = message(msg) { "Expected '#{filename}' not to exist" }
    refute_path_exists("_site/#{filename}", msg)
  end
end

module TestServer
  def kill_jekyll_test_server
    process_ids = `pgrep jekyll`

    process_ids&.split("\n")&.each do |process_id|
      system("kill -9 #{process_id}")
    end
  end

  def start_jekyll_test_server
    system("JEKYLL_ENV=test bundle exec jekyll serve --detach --port=1234")
  end
end

class IntegrationTestCase < Minitest::Test
  include Minitest::Hooks
  include TestServer

  def before_all
    start_jekyll_test_server
  end

  def after_all
    kill_jekyll_test_server
  end

  def read_file(path)
    File.read("_site/#{path}")
  end
end

class SystemTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def check_for_broken_images(current_path)
    page.all("img").each do |img|
      path = img[:src]

      visit path
      assert_equal 200, page.status_code, "Expected image #{path} to exist on #{current_path}"
    end
  end

  def list_of_paths
    visit "sitemap.xml"

    page.all("loc").map { |item| item.text }.uniq.sort
  end

  def visit_all_paths
    paths = list_of_paths

    paths.each do |path|
      visit path

      visit_html_path(path) if page.status_code != 200
      yield
    end
  end

  def visit_html_path(path)
    visit path.concat(".html")

    if page.status_code != 200
      flunk "Expected #{current_url} to exist."
    end
  end
end
