# Scrape the feed using the "Scrape" library
defmodule FeedStage.FeedScraper.Scrape do
  def get_articles(url) do
    Scrape.feed url
  end
end
