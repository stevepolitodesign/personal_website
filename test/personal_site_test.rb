require "test_helper"

class BuildTest < IntegrationTestCase
  def test_exluded_files
    refute_exist("Rakefile")
    refute_exist("test")
    refute_exist("README.md")
    refute_exist("bin")
    refute_exist("node_modules")
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

class SystemTest < SystemTestCase
  def test_image_paths
    visit_all_paths do |path|
      check_for_broken_images(current_url)
    end
  end

  def test_all_pages_have_meta_data
    visit_all_paths do |path|
      description = page.find("meta[name='description']", visible: false)[:content]
      title = page.find("title", visible: false).native.text
      og_title = page.find("meta[property='og:title']", visible: false)[:content]
      og_image = page.find("meta[property='og:image']", visible: false)[:content]
      twitter_card = page.find("meta[property='twitter:card']", visible: false)[:content]
      twitter_title = page.find("meta[property='twitter:title']", visible: false)[:content]

      refute_empty description
      refute_empty title
      refute_empty og_title
      refute_empty og_image
      refute_empty twitter_card
      refute_empty twitter_title
    end
  end

  def test_category_archive_meta_data
    visit "/categories/ruby-on-rails"
    description = page.find("meta[name='description']", visible: false)[:content]

    assert_match "Latest blog posts categorized in Ruby on Rails", description
  end

  def test_tag_archive_meta_data
    visit "/tags/opinion"
    description = page.find("meta[name='description']", visible: false)[:content]

    assert_match "Latest blog posts tagged as Opinion", description
  end

  def test_post_with_no_meta_data
    visit_post "post_with_no_meta_data"
    description = page.find("meta[name='description']", visible: false)[:content]
    title = page.find("title", visible: false).native.text
    og_title = page.find("meta[property='og:title']", visible: false)[:content]
    og_image = page.find("meta[property='og:image']", visible: false)[:content]
    twitter_card = page.find("meta[property='twitter:card']", visible: false)[:content]
    twitter_title = page.find("meta[property='twitter:title']", visible: false)[:content]

    assert_match "Post with no meta data", description
    assert_match "Post with no meta data", title
    assert_match "Post with no meta data", og_title
    assert_match "https://stevepolito.design/assets/images/og_image.jpg", og_image
    assert_match "summary_large_image", twitter_card
    assert_match "Post with no meta data", twitter_title
  end

  def test_post_with_meta_data
    visit_post "post_with_meta_data"
    description = page.find("meta[name='description']", visible: false)[:content]
    og_image = page.find("meta[property='og:image']", visible: false)[:content]

    assert_match "Custom excerpt", description
    assert_match "https://stevepolito.design/assets/images/posts/post-with-meta-data/custom_og_image.jpg", og_image
  end

  def test_page_titles
    visit_all_paths do |path|
      title = page.find("main h1").text

      refute_empty title
    end
  end

  class HomePageTest < SystemTest
    def test_title
      visit "/"

      within "main" do
        page.assert_selector "h1", text: "Steve Polito is a full stack web developer in the Boston Area"
      end
    end

    def test_latest_posts
      visit "/"

      within "main section[role='region'][aria-labelledby='latest-posts']" do
        page.assert_selector "h2", text: "Latest Posts", id: "latest-posts"
        page.assert_selector "article", count: 3

        within "article:first-of-type" do
          page.assert_selector "header h2"
          page.assert_selector "header h2 ~ p", count: 1
          page.assert_selector "header h2 ~ a", count: 1, text: "Read More"
        end
      end
    end
  end

  class LayoutTest < SystemTest
    def test_navigation
      visit_all_paths do |path|
        within "body header[role='banner'] nav ul" do
          assert_link "Blog", href: "/blog"
          assert_link "Contact", href: "/contact"
        end
      end
    end
  end

  class BlogTest < SystemTest
    def test_blog
      visit "blog.html"

      within "main section[role='region'][aria-labelledby='latest-posts']" do
        page.assert_selector "h2", text: "Latest Posts", id: "latest-posts"

        within "article:first-of-type" do
          page.assert_selector "header h2"
          page.assert_selector "header h2 ~ p", count: 1
          page.assert_selector "header h2 ~ a", count: 1, text: "Read More"
        end
      end
    end

    def test_video
      visit_post "post_with_video"
      description = page.find("meta[name='description']", visible: false)[:content]

      assert_match "Post with video", description
      within "div.ratio.ratio-16x9" do
        page.assert_selector "iframe[src='https://www.youtube.com/embed/123?rel=0']"
      end
    end
  end

  class ArchiveTest < SystemTest
    def test_category
      visit "categories/ruby-on-rails"

      within "main section[role='region'][aria-labelledby='latest-posts']" do
        page.assert_selector "h2", text: "Latest Posts", id: "latest-posts"

        within "article:first-of-type" do
          page.assert_selector "header h2"
          page.assert_selector "header h2 ~ p", count: 1
          page.assert_selector "header h2 ~ a", count: 1, text: "Read More"
        end
      end
    end

    def test_tag
      visit "tags/opinion"

      within "main section[role='region'][aria-labelledby='latest-posts']" do
        page.assert_selector "h2", text: "Latest Posts", id: "latest-posts"

        within "article:first-of-type" do
          page.assert_selector "header h2"
          page.assert_selector "header h2 ~ p", count: 1
          page.assert_selector "header h2 ~ a", count: 1, text: "Read More"
        end
      end
    end
  end
end
