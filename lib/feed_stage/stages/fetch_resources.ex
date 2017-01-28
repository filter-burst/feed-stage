defmodule FeedStage.Stages.FetchResources do
  use GenStage

  def start_link(resource_fetcher \\ HTTPoison) do
    GenStage.start_link(__MODULE__, resource_fetcher, name: __MODULE__)
  end

  def init(resource_fetcher) do
    state = %{resource_fetcher: resource_fetcher}
    {:producer_consumer, state}
  end

  def handle_events(urls, _from, state) do
    output = Enum.map(urls, fn(url) -> fetch_resource(url, state) end)
    output = Enum.reject(output, &(&1 == nil))
    {:noreply, output, state}
  end

  # ----------------------- PRIVATE -----------------------

  defp fetch_resource(url, state) do
    handle_response state.resource_fetcher.get(url)
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200} = response}), do: response.body
  defp handle_response(_), do: nil
end
