defmodule FeedStage.Stages.FetchMetadata do
  use GenStage

  def start_link(parser \\ FeedStage.Parser) do
    GenStage.start_link(__MODULE__, parser, name: __MODULE__)
  end

  def init(parser) do
    {:producer_consumer, parser}
  end

  def handle_events(articles, _from, parser) do
    output = Enum.map(articles, fn(article) -> fetch_article_metadata(article, parser) end)
    output = Enum.filter(output, fn(result) -> result != nil end)
    {:noreply, output, parser}
  end

  # ----------------------- PRIVATE -----------------------

  defp fetch_article_metadata(article, parser) do
    case parser.scrape_article(article.url) do
      {:error, _} -> nil
      {:ok, metadata} -> merge_metadata(article, metadata)
    end
  end

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
