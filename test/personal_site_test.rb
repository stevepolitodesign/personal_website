require "test_helper"

class BuildTest < IntegrationTestCase
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
