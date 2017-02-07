defmodule InspectingConsumer do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  def init(state) do
    {:consumer, state, []}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      IO.puts "EVENT"
      IO.inspect {self(), event, state}
      IO.puts "--------------"
    end

    # As a consumer we never emit events
    {:noreply, [], state}
  end
end

defmodule FeedStage.CLI do
  alias FeedStage.UrlRepository.InMemory, as: UrlRepository
  alias FeedStage.ArticleRepository.InMemory, as: ArticleRepository

  def start_pipeline(url_repository, article_repository) do
    {:ok, feed_resource_urls} = FeedStage.Stages.FeedResourceUrls.start_link(url_repository)
    {:ok, fetch_resources} = FeedStage.Stages.FetchResources.start_link
    {:ok, parse_feeds} = FeedStage.Stages.ParseFeeds.start_link
    {:ok, inspector} = InspectingConsumer.start_link
    {:ok, all_articles} = FeedStage.Stages.AllArticles.start_link()
    {:ok, new_articles} = FeedStage.Stages.NewArticles.start_link(article_repository)
    {:ok, fetch_metadata} = FeedStage.Stages.FetchMetadata.start_link()

    GenStage.sync_subscribe(fetch_resources, to: feed_resource_urls, min_demand: 1, max_demand: 10)
    GenStage.sync_subscribe(parse_feeds, to: fetch_resources, min_demand: 1, max_demand: 10)
    GenStage.sync_subscribe(all_articles, to: parse_feeds, min_demand: 10, max_demand: 50)
    GenStage.sync_subscribe(new_articles, to: all_articles, min_demand: 10, max_demand: 50)
    GenStage.sync_subscribe(fetch_metadata, to: new_articles, min_demand: 10, max_demand: 50)
    GenStage.sync_subscribe(inspector, to: fetch_metadata, min_demand: 1, max_demand: 2)
  end

  def start_dummy do
    IO.puts "starting dummy"
    HTTPoison.start

    UrlRepository.start_link
    UrlRepository.set([
      "http://feeds.feedburner.com/venturebeat/SZYF",
      "https://medium.com/feed/@lasseebert",
      "http://lorem-rss.herokuapp.com/feed?unit=second&interval=5"])

    ArticleRepository.start_link

    start_pipeline(UrlRepository, ArticleRepository)
  end

  def main(_argv \\ []) do
    start_dummy()
  end
end
