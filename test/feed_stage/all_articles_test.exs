defmodule FeedStage.AllArticlesTest do
  use ExUnit.Case
  alias FeedStage.UrlRepository.MockRepository
  alias FeedStage.AllArticles

  setup do
    MockRepository.start_link
  end

  test "with no available urls, no events are emmitted" do
    scraper = Stubr.stub!([])
    state = %{url_repository: MockRepository, feed_scraper: scraper, buffer: []}

    assert {:noreply, [], _} = AllArticles.handle_demand(10, state)
  end

  test "where the first url has sufficient articles to meet demand" do
    MockRepository.set(["url1"])
    scraper = Stubr.stub!([get_articles: fn "url1" -> [1,2,3,4] end])
    state = %{url_repository: MockRepository, feed_scraper: scraper, buffer: []}

    assert {:noreply, events, _} = AllArticles.handle_demand(4, state)
    assert Enum.count(events) == 4
  end

  test "where the first url has more articles than demanded it saves some for the next call" do
    MockRepository.set(["url1"])
    scraper = Stubr.stub!([get_articles: fn "url1" -> [1,2,3,4,5,6,7] end])
    state = %{url_repository: MockRepository, feed_scraper: scraper, buffer: []}

    assert {:noreply, [1,2,3], output_state} = AllArticles.handle_demand(3, state)
    assert [4,5,6,7] == output_state.buffer
  end

  test "when there are enough articles in the buffer, use those instead of fetching" do
    MockRepository.set(["url1"])
    scraper = Stubr.stub!([get_articles: fn "url1" -> [1,2,3,4,5,6,7] end])
    state = %{url_repository: MockRepository, feed_scraper: scraper, buffer: [8,9,10,11]}

    assert {:noreply, [8,9,10], output_state} = AllArticles.handle_demand(3, state)
    assert [11] == output_state.buffer
  end
end
