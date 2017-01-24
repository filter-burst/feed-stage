
# Can fetch a feed like this:
# Scrape.feed "http://feeds.feedburner.com/venturebeat/SZYF"

# Notes
# When demand comes in, scrape a feed, and return as many articles as meets
# the demand. If there are more articles than the demand, store the rest in the
# state until the next handle demand call. If there are not enough articles to
# meet the demand, grab the next url and fetch those too.

defmodule FeedStage.AllArticles do
  use GenStage

  def start_link(initial \\ 0) do
    GenStage.start_link(__MODULE__, :no_repo, name: __MODULE__)
  end

  @doc """
  Prints a hello message

  ## Parameters

    - url_repository: A module which can provide the next feed url to check, and
      also can be used to mark a url as checked.
    - url_scraper: A module that has a function to scrape a url.
  """
  def init(url_repository) do
    {:producer, :unused_state}
  end

  def handle_demand(demand, state) when demand > 0 do
    {:noreply, things = [:whatever, :you, :want], state}
  end
end
