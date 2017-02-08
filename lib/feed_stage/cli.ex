

defmodule FeedStage.CLI do
  def start_dummy do
    IO.puts "starting pipeline with dummy feeds"

    # Some dummy urls to parse
    urls = [
      "http://feeds.feedburner.com/venturebeat/SZYF",
      "https://medium.com/feed/@lasseebert",
      "http://lorem-rss.herokuapp.com/feed?unit=second&interval=5"
    ]

    pipeline = FeedStage.Pipeline.start(urls: urls)

    # This inspector just dumps the results to STDOUT
    {:ok, inspector} = FeedStage.Stages.DummyConsumer.start_link
    GenStage.sync_subscribe(inspector, to: pipeline, min_demand: 1, max_demand: 2)
  end

  def main(_argv \\ []) do
    start_dummy()
  end
end
