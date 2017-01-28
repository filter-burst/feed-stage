
defmodule FeedStage.Stages.AllFeeds do
  use GenStage
  use FeedStage.StageHelpers.BuffersDemand
  use FeedStage.StageHelpers.BuffersSupply

  def start_link(args \\ {}) do
    GenStage.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  ## Parameters

    - url_repository: A module which can provide the next feed url to check, and
      also can be used to mark a url as checked.
    - feed_scraper: A module that has a function to scrape a url.
  """
  def init({url_repository, feed_scraper}) do
    state = %{
      url_repository: url_repository,
      feed_scraper: feed_scraper || FeedStage.FeedScraper.Scrape,
      buffer: [],
      demand: 0
    }
    {:producer, state}
  end

  def handle_demand(demand, state) when demand > 0 do
    state = buffer_demand(demand, state)
    state = buffer_demanded_feeds(state.demand, state)
    {feeds, state} = retrieve_items_from_buffer(state.demand, state)
    {:noreply, feeds, state}
  end

  # ----------------------- PRIVATE -----------------------

  defp buffer_demanded_feeds(demand, state) do
    if length(state.buffer) < demand do
      case buffer_feeds(state) do
        {:ok, state} ->     buffer_demanded_feeds(demand, state)
        {:no_url, state} -> state
      end
    else
      state
    end
  end

  defp buffer_feeds(state) do
    url = state.url_repository.pop_url()
    buffer_feed_from_url(url, state)
  end

  defp buffer_feed_from_url(url, state) when url == nil, do: {:no_url, state}
  defp buffer_feed_from_url(url, state) do
    articles = state.feed_scraper.get_articles(url)
    {:ok, add_items_to_buffer([articles], state)}
  end
end
