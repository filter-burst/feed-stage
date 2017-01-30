defmodule FeedStage.Stages.FeedResourceUrls do
  use GenStage
  use FeedStage.StageHelpers.BuffersDemand

  def start_link(url_repository) do
    GenStage.start_link(__MODULE__, url_repository, name: __MODULE__)
  end

  def init(url_repository) do
    state = %{url_repository: url_repository, demand: 0}
    {:producer, state}
  end

  def handle_demand(demand, state) when demand > 0 do
    state = buffer_demand(demand, state)
    urls = state.url_repository.pop(state.demand)
    state = reduce_demand_by(length(urls), state)
    {:noreply, urls, state}
  end
end
