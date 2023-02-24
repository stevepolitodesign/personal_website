require "minitest/autorun"
require "minitest/hooks/test"
require "minitest/rg"
require "capybara/minitest"
require "rack/jekyll"
require "axe/matchers/be_axe_clean"

ENV["JEKYLL_ENV"] ||= "test"

system("bundle exec jekyll build", out: File::NULL)
Capybara.app = Rack::Jekyll.new
Capybara.default_driver = :selenium_chrome_headless
Capybara.server = :webrick

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
    system("bundle exec jekyll serve --detach --port=1234", out: File::NULL)
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
    Capybara.current_driver = :rack_test
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
    Capybara.current_driver = :rack_test
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

  def visit_post(path)
    Capybara.current_driver = :rack_test
    visit_html_path("/fixtures/#{path}")
  end

  def assert_accessible(page, matcher = Axe::Matchers::BeAxeClean.new.according_to(:wcag21aa, "best-practice"))
    audit_result = matcher.audit(page)
    assert(audit_result.passed?, audit_result.failure_message)
  end
end
