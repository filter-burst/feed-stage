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
  def start_dummy do
    IO.puts "starting dummy"
    FeedStage.UrlRepository.MockRepository.start_link
    FeedStage.UrlRepository.MockRepository.set(["http://feeds.feedburner.com/venturebeat/SZYF", "https://medium.com/feed/@lasseebert"])

    {:ok, all_feeds} = FeedStage.Stages.AllFeeds.start_link({FeedStage.UrlRepository.MockRepository, nil})
    {:ok, all_articles} = FeedStage.Stages.AllArticles.start_link()
    {:ok, inspector} = InspectingConsumer.start_link

    GenStage.sync_subscribe(all_articles, to: all_feeds)
    GenStage.sync_subscribe(inspector, to: all_articles)
  end

  def main(_argv \\ []) do
    start_dummy()
  end
end
