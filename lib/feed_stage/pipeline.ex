defmodule FeedStage.Pipeline do
  def start(options) do
    %{
      url_repository: url_repository,
      article_repository: article_repository
    } = Enum.into(options, %{})

    {:ok, feed_resource_urls} = FeedStage.Stages.FeedResourceUrls.start_link(url_repository)
    {:ok, fetch_resources} = FeedStage.Stages.FetchResources.start_link
    {:ok, parse_feeds} = FeedStage.Stages.ParseFeeds.start_link
    {:ok, all_articles} = FeedStage.Stages.AllArticles.start_link()
    {:ok, new_articles} = FeedStage.Stages.NewArticles.start_link(article_repository)
    {:ok, fetch_metadata} = FeedStage.Stages.FetchMetadata.start_link()

    GenStage.sync_subscribe(fetch_resources, to: feed_resource_urls, min_demand: 1, max_demand: 10)
    GenStage.sync_subscribe(parse_feeds, to: fetch_resources, min_demand: 1, max_demand: 10)
    GenStage.sync_subscribe(all_articles, to: parse_feeds, min_demand: 10, max_demand: 50)
    GenStage.sync_subscribe(new_articles, to: all_articles, min_demand: 10, max_demand: 50)
    GenStage.sync_subscribe(fetch_metadata, to: new_articles, min_demand: 10, max_demand: 50)

    fetch_metadata
  end


end
