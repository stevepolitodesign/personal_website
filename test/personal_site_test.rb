require "test_helper"

class BuildTest < IntegrationTestCase
  def test_exluded_files
    refute_exist("Rakefile")
    refute_exist("test")
    refute_exist("README.md")
    refute_exist("bin")
  end

  def test_included_files
    assert_exist("_redirects")
    assert_exist("404.html")
    assert_exist("sitemap.xml")
  end

  def test_redirects
    expected = <<~TEXT
      /categories/ja-mstack /categories/jamstack
      /categories/word-press /categories/wordpress
      /portfolio /
      /tags/blue-host /tags/bluehost
      /tags/flex-slider /tags/flexslider
      /tags/r-spec /tags/rspec
      /blog/use-htmlentities-to-format-alt-tags /blog/use-esc_attr-to-format-alt-tags
    TEXT
    actual = read_file("_redirects")

    assert_equal expected, actual
  end
end
