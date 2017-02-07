defmodule FeedStage.Stages.FetchMetadata do
  use GenStage

  def start_link(parser \\ FeedStage.Parser) do
    GenStage.start_link(__MODULE__, parser, name: __MODULE__)
  end

  def init(parser) do
    {:producer_consumer, parser}
  end

  def handle_info({_ref, {:parse_error}}, state) do
    IO.puts "-- RECEIVED :parse_error"
    {:noreply, [], state}
  end

  def handle_info({_ref, {:parsed_ok, article_with_metadata}}, state) do
    {:noreply, [article_with_metadata], state}
  end

  def handle_info({:DOWN, _ref, :process, _pid, :normal}, state) do
    {:noreply, [], state}
  end

  def handle_events(articles, _from, parser) do
    Enum.map(articles, &Task.async(fn -> fetch_article_metadata(&1, parser) end))
    {:noreply, [], parser}
  end

  def fetch_article_metadata(article, parser) do
    IO.puts "-- fetching metadata #{article.url}"
    case parser.scrape_article(article.url) do
      {:error, _} -> {:parse_error}
      {:ok, metadata} -> {:parsed_ok, merge_metadata(article, metadata)}
    end
  end

  # ----------------------- PRIVATE -----------------------

  defp merge_metadata(article, metadata) do
    Map.merge(article, filter_useful_metadata(metadata))
  end

  defp filter_useful_metadata(metadata) do
    metadata
    |> Map.from_struct
    |> Enum.filter(fn {_, value} -> value != nil && value != "" && value != [] end)
    |> Enum.into(%{})
  end
end
