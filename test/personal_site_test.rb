require "test_helper"

class BuildTest < IntegrationTestCase
  def test_exluded_files
    refute_exist("Rakefile")
    refute_exist("test")
    refute_exist("README.md")
    refute_exist("bin")
    refute_exist("node_modules")
    refute_exist("package.json")
    refute_exist("yarn.lock")
    refute_exist(".husky")
  end

  def test_included_files
    assert_exist("_redirects")
    assert_exist("404.html")
    assert_exist("sitemap.xml")
    assert_exist("apple-touch-icon.png")
    assert_exist("favicon-32x32.png")
    assert_exist("favicon-16x16.png")
    assert_exist("site.webmanifest")
    assert_exist("safari-pinned-tab.svg")
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

  def test_config
    config = YAML.load(File.read("_config.yml"))

    assert_equal "/", config["baseurl"]
    assert_equal "Steve Polito Design", config["title"]
  end
end

class SystemTest < SystemTestCase
  def test_image_paths
    visit_all_paths do |path|
      check_for_broken_images(current_url)
    end
  end

  def test_contact_form
    visit "/contact.html"

    within "form[name='contact'][data-netlify='true'][method='POST'][action='/thanks/']" do
      assert_field "name"
      assert_field "email"
      assert_field "message"
    end
  end

  class MetaDataTest < SystemTest
    def test_all_pages_have_favicon
      visit_all_paths do |path|
        page.find("link[rel='apple-touch-icon'][sizes='180x180'][href='/apple-touch-icon.png']", visible: false)
        page.find("link[rel='icon'][sizes='32x32'][type='image/png'][href='/favicon-32x32.png']", visible: false)
        page.find("link[rel='icon'][sizes='16x16'][type='image/png'][href='/favicon-16x16.png']", visible: false)
        page.find("link[rel='manifest'][href='/site.webmanifest']", visible: false)
        page.find("link[rel='mask-icon'][href='/safari-pinned-tab.svg'][color='#dc3545']", visible: false)
        page.find("meta[name='msapplication-TileColor'][content='#da532c']", visible: false)
        page.find("meta[name='theme-color'][content='#ffffff']", visible: false)
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
        canonical_url = page.find("link[rel='canonical']", visible: false)[:content]

        refute_empty description
        refute_empty title
        refute_empty og_title
        refute_empty og_image
        refute_empty twitter_card
        refute_empty twitter_title
        refute_empty canonical_url
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
      assert_equal "Post with no meta data", title
      assert_match "Post with no meta data", og_title
      assert_match "/assets/images/og_image.jpg", og_image
      assert_match "summary_large_image", twitter_card
      assert_match "Post with no meta data", twitter_title
    end

    def test_post_with_meta_data
      visit_post "post_with_meta_data"
      description = page.find("meta[name='description']", visible: false)[:content]
      og_image = page.find("meta[property='og:image']", visible: false)[:content]
      canonical_url = page.find("link[rel='canonical']", visible: false)[:content]
      title = page.find("title", visible: false).native.text

      assert_match "Custom excerpt", description
      assert_match "https://stevepolito.design/assets/images/posts/post-with-meta-data/custom_og_image.jpg", og_image
      assert_match "https://stevepolito.design/fixtures/post_with_meta_data", canonical_url
      assert_equal "Post with meta data", title
    end

    def test_page_titles
      visit_all_paths do |path|
        title = page.find("main h1.long-shadow").text

        refute_empty title
      end
    end
  end

  class HomePageTest < SystemTest
    def test_title
      visit "/"

      assert_accessible page
      assert_equal "Steve Polito is a full stack web developer in the Boston Area", page.title
      within "main" do
        page.assert_selector "h1", text: "Steve Polito is a full stack web developer in the Boston Area"
      end
    end

    def test_latest_posts
      visit "/"

      within "main section[role='region'][aria-labelledby='latest-posts']" do
        page.assert_selector "h2", text: "Latest Posts", id: "latest-posts"
        page.assert_selector "article", count: 3
        assert_link "View All Posts", href: "/blog"

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
        within "body header[role='banner']" do
          assert_link href: "/"
        end
        within "body header[role='banner'] nav" do
          assert_link "Blog", href: "/blog"
          assert_link "Contact", href: "/contact"
          assert_selector "a[aria-label='Twitter'][href='https://twitter.com/stevepolitodsgn']"
          assert_selector "a[aria-label='GitHub'][href='https://github.com/stevepolitodesign']"
        end
      end
    end

    def test_sidebar
      visit "contact.html"

      within "main aside" do
        page.assert_selector "p", text: "References", count: 0
      end
    end
  end

  class BlogTest < SystemTest
    def test_blog
      visit "blog.html"

      assert_accessible page
      assert_equal "Latest posts from Steve Polito", page.title
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

    def test_resources
      visit_post "post_with_resources"

      within "main aside" do
        page.assert_selector "p", text: "References"

        within "ul li" do
          assert_link "Resource One", href: "https://example.com"
        end
      end
    end

    def test_resources_as_json
      visit_post "post_with_resources_as_json"

      within "main aside" do
        page.assert_selector "p", text: "References"

        within "ul li" do
          assert_link "Resource One", href: "https://example.com"
        end
      end
    end

    def test_no_resources
      visit_post "post_with_video"

      within "main aside" do
        page.assert_selector "p", text: "References", count: 0
      end
    end

    def test_tags_and_categories
      visit_post "post_with_tags"

      within "main aside" do
        assert_link "Ruby on Rails", href: "/categories/ruby-on-rails"
        assert_link "Tutorial", href: "/tags/tutorial"
      end
    end

    def test_tags_and_categories_on_post
      visit "blog.html"

      within "main aside" do
        assert_selector "p", text: "Categories"
        assert_selector "p", text: "Tags"
        assert_selector "ul li"
        assert_link "Ruby on Rails", href: "/categories/ruby-on-rails"
        assert_link "Tutorial", href: "/tags/tutorial"
      end
    end

    def test_post_navigation
      visit_post "post_with_no_meta_data"

      assert_selector "nav[aria-label='Post navigation']"
    end

    def test_image_links
      visit_post "post_with_image"

      within "a[href='./assets/some/image.png']" do
        assert_selector "img[src='./assets/some/image.png']"
        assert_selector "span", text: "Click to expand"
      end
      within "a[href='./assets/another/image.png']" do
        assert_selector "img[src='./assets/another/image.png']"
        assert_selector "span", text: "Click to expand"
      end
      assert_no_selector "a[href='./assets/existing/link/image.png']"
    end

    def test_headlines
      visit_post "post_with_headlines"

      within "h1#headline-1" do
        assert_selector "a[href='#headline-1'][aria-label='Headline 1']"
      end
      within "h2#headline-2" do
        assert_selector "a[href='#headline-2'][aria-label='Headline 2']"
      end
    end
  end

  class ArchiveTest < SystemTest
    def test_category
      visit "categories/ruby-on-rails"

      assert_accessible page
      assert_equal "Latest Ruby on Rails posts from Steve Polito", page.title
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

      assert_accessible page
      assert_equal "Latest Opinion posts from Steve Polito", page.title
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
