defmodule FeedStage.AllFeedsTest do
  use ExUnit.Case
  alias FeedStage.UrlRepository.MockRepository
  alias FeedStage.AllFeeds

  setup do
    MockRepository.start_link
  end

  test "with no available urls, no events are emmitted" do
    state = stub_state()
    assert {:noreply, [], _} = AllFeeds.handle_demand(2, state)
  end

  test "with available urls, parse enough to meet demand" do
    state = stub_state(%{"url1" => 1, "url2" => 2, "url3" => 3})
    assert {:noreply, [1,2], _} = AllFeeds.handle_demand(2, state)
  end

  # --------- HELPERS ------------

  defp stub_scraper(url_mappings) do
    Stubr.stub!([
      get_articles: fn url ->
        url_mappings[url]
      end
    ])
  end

  defp stub_state(url_mappings \\ %{}, other_args \\ %{}) do
    urls = Map.keys(url_mappings)
    MockRepository.set(urls)
    scraper = stub_scraper(url_mappings)
    result = %{
      url_repository: MockRepository,
      feed_scraper: scraper,
      feed_buffer: [],
      demand: 0,
    }
    Map.merge(result, Enum.into(other_args, %{}))
  end
end
