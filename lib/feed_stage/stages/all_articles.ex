defmodule FeedStage.Stages.AllArticles do
  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:producer_consumer, :the_state_does_not_matter}
  end

  def handle_events(feeds, _from, state) do
    {:noreply, List.flatten(feeds), state}
  end
end
