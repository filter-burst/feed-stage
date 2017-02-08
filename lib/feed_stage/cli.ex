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
    HTTPoison.start

    urls = [
      "http://feeds.feedburner.com/venturebeat/SZYF",
      "https://medium.com/feed/@lasseebert",
      "http://lorem-rss.herokuapp.com/feed?unit=second&interval=5"
    ]

    pipeline = FeedStage.Pipeline.start(
      urls: urls
    )

    # This inspector just dumps the results to STDOUT
    {:ok, inspector} = InspectingConsumer.start_link
    GenStage.sync_subscribe(inspector, to: pipeline, min_demand: 1, max_demand: 2)
  end

  def main(_argv \\ []) do
    start_dummy()
  end
end
