defmodule FeedStage.Stages.AllFeedsTest do
  use ExUnit.Case
  alias FeedStage.UrlRepository.MockRepository
  alias FeedStage.Stages.AllFeeds

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

  test "with insufficient urls to meet demand, buffer demand and return what you have" do
    state = stub_state(%{"url1" => 1, "url2" => 2, "url3" => 3})

    assert {:noreply, [1,2,3], output_state} = AllFeeds.handle_demand(5, state)
    assert 2 == output_state.demand
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
      buffer: [],
      demand: 0,
    }
    Map.merge(result, Enum.into(other_args, %{}))
  end
end
