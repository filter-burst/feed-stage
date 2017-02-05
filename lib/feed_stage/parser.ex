defmodule FeedStage.Parser do
  def parse_feed(feed_text) do
    Scrape.Feed.parse(feed_text, :unused)
  end

  def scrape_article(url) do
    html = Scrape.Fetch.run url
    if html == "" do
      {:error, nil}
    else
      website = Scrape.Website.parse(html, url)
      article = Scrape.Article.parse(website, html)
      {:ok, article}
    end
  end
end
