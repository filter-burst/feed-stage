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

    assert {:noreply, events, output_state} = AllArticles.handle_demand(4, state)
    assert length(events) == 4
    assert 0 == output_state.demand
  end

  test "where the first url has more articles than demanded it saves some for the next call" do
    state = stub_state(%{"url1" => [1,2,3,4,5,6,7]})

    assert {:noreply, [1,2,3], output_state} = AllArticles.handle_demand(3, state)
    assert [4,5,6,7] == output_state.article_buffer
  end

  test "when there are enough articles in the buffer, use those instead of fetching" do
    state = stub_state(%{"url1" => [1,2,3,4,5,6,7]}, article_buffer: [8,9,10,11])

    assert {:noreply, [8,9,10], output_state} = AllArticles.handle_demand(3, state)
    assert [11] == output_state.article_buffer
  end

  test "keep fetching feeds until enough articles are available to meet demand" do
    state = stub_state(%{"url1" => [1,2], "url2" => [3], "url3" => [4,5,6]})

    assert {:noreply, [1,2,3,4,5], output_state} = AllArticles.handle_demand(5, state)
    assert [6] == output_state.article_buffer
  end

  test "if you run out of feeds, buffer demand and return what you have" do
    state = stub_state(%{"url1" => [1,2], "url2" => [3]})

    assert {:noreply, [1,2,3], output_state} = AllArticles.handle_demand(5, state)
    assert [] == output_state.article_buffer
    assert 2 == output_state.demand
  end

  test "if possible, handle buffered demand when handling demand" do
    state = stub_state(%{"url1" => [1,2,3,4,5,6,7]}, demand: 2)

    assert {:noreply, [1,2,3,4,5], output_state} = AllArticles.handle_demand(3, state)
    assert [6,7] == output_state.article_buffer
    assert 0 == output_state.demand
  end

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
    result = %{
      url_repository: MockRepository,
      feed_scraper: scraper,
      article_buffer: [],
      demand: 0,
    }
    Map.merge(result, Enum.into(other_args, %{}))
  end
end
