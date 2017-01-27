defmodule FeedStage.AllArticlesTest do
  use ExUnit.Case
  alias FeedStage.UrlRepository.MockRepository
  alias FeedStage.AllArticles

  setup do
    MockRepository.start_link
  end

  test "with no available urls, no events are emmitted" do
    state = stub_state()

    assert {:noreply, [], _} = AllArticles.handle_demand(10, state)
  end

  test "where the first url has sufficient articles to meet demand" do
    state = stub_state(%{"url1" => [1,2,3,4]})

    assert {:noreply, events, _} = AllArticles.handle_demand(4, state)
    assert Enum.count(events) == 4
  end

  test "where the first url has more articles than demanded it saves some for the next call" do
    state = stub_state(%{"url1" => [1,2,3,4,5,6,7]})

    assert {:noreply, [1,2,3], output_state} = AllArticles.handle_demand(3, state)
    assert [4,5,6,7] == output_state.buffer
  end

  test "when there are enough articles in the buffer, use those instead of fetching" do
    state = stub_state(%{"url1" => [1,2,3,4,5,6,7]}, buffer: [8,9,10,11])

    assert {:noreply, [8,9,10], output_state} = AllArticles.handle_demand(3, state)
    assert [11] == output_state.buffer
  end

  # test "keep fetching feeds until enough articles are available to meet demand"
  #
  # test "if you run out of feeds, give up and return what you have"
  #
  # test "if there is a problem fetching a url, tell the url repository"

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
    result = %{url_repository: MockRepository, feed_scraper: scraper, buffer: []}
    Map.merge(result, Enum.into(other_args, %{}))
  end
end
