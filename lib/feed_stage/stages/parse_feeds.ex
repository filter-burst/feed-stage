defmodule FeedStage.Stages.ParseFeeds do
  use GenStage

  def start_link(parser \\ FeedStage.Parser) do
    GenStage.start_link(__MODULE__, parser, name: __MODULE__)
  end

  def init(parser) do
    {:producer_consumer, parser}
  end

  def handle_events(resources, _from, parser) do
    output = Enum.map(resources, &(parser.parse_feed(&1)))
    output = Enum.reject(output, &(&1 == nil))
    IO.puts "ParseFeeds #{length(resources)}"

    {:noreply, output, parser}
  end
end
