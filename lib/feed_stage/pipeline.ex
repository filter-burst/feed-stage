defmodule FeedStage.Pipeline do
  alias FeedStage.Stages.FeedResourceUrls
  alias FeedStage.Stages.FetchResources
  alias FeedStage.Stages.ParseFeeds
  alias FeedStage.Stages.AllArticles
  alias FeedStage.Stages.NewArticles
  alias FeedStage.Stages.FetchMetadata

  def start(options) do
    {url_repository, article_repository} = options_with_defaults(options)

    # Used by FetchResources
    HTTPoison.start

    {:ok, feed_resource_urls} = FeedResourceUrls.start_link(url_repository)
    {:ok, fetch_resources} = FetchResources.start_link
    {:ok, parse_feeds} = ParseFeeds.start_link
    {:ok, all_articles} = AllArticles.start_link()
    {:ok, new_articles} = NewArticles.start_link(article_repository)
    {:ok, fetch_metadata} = FetchMetadata.start_link()

    GenStage.sync_subscribe(fetch_resources, to: feed_resource_urls, min_demand: 1, max_demand: 10)
    GenStage.sync_subscribe(parse_feeds, to: fetch_resources, min_demand: 1, max_demand: 10)
    GenStage.sync_subscribe(all_articles, to: parse_feeds, min_demand: 10, max_demand: 50)
    GenStage.sync_subscribe(new_articles, to: all_articles, min_demand: 10, max_demand: 50)
    GenStage.sync_subscribe(fetch_metadata, to: new_articles, min_demand: 10, max_demand: 50)

    fetch_metadata
  end

  # ----------------------- PRIVATE -----------------------

  def options_with_defaults(options) do
    defaults = [url_repository: nil, article_repository: nil, urls: nil]
    options = Keyword.merge(defaults, options) |> Enum.into(%{})
    %{
      url_repository: url_repository,
      article_repository: article_repository,
      urls: urls
    } = options
    article_repository = article_repository || in_memory_article_repository()
    url_repository = url_repository || in_memory_url_repository(urls)

    {url_repository, article_repository}
  end

  defp in_memory_article_repository do
    FeedStage.ArticleRepository.InMemory.start_link
    FeedStage.ArticleRepository.InMemory
  end

  defp in_memory_url_repository(urls) do
    FeedStage.UrlRepository.InMemory.start_link
    FeedStage.UrlRepository.InMemory.set(urls)
    FeedStage.UrlRepository.InMemory
  end
end
