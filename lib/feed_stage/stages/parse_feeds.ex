defmodule FeedStage.Stages.ParseFeeds do
  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer_consumer, :unused_state}
  end

  def handle_events(resources, _from, state) do
    output = Enum.map(resources, &parse_resource/1)
    output = Enum.reject(output, &(&1 == nil))
    {:noreply, output, state}
  end

  # ----------------------- PRIVATE -----------------------

  defp parse_resource(resource) do
    Scrape.Feed.parse(resource, :unused)
  end
end
