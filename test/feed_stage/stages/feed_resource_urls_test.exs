defmodule FeedStage.Stages.FeedResourceUrlsTest do
  use ExUnit.Case
  alias FeedStage.UrlRepository.MockRepository
  alias FeedStage.Stages.FeedResourceUrls

  setup do
    MockRepository.start_link
  end

  test "with no available urls, no events are emmitted" do
    state = stub_state()
    assert {:noreply, [], _} = FeedResourceUrls.handle_demand(2, state)
  end

  test "with available urls, parse enough to meet demand" do
    state = stub_state(["url1", "url2", "url3"])
    assert {:noreply, ["url1", "url2"], _} = FeedResourceUrls.handle_demand(2, state)
  end

  test "with insufficient urls to meet demand, buffer demand and return what you have" do
    state = stub_state(["url1", "url2", "url3"])

    assert {:noreply, ["url1", "url2", "url3"], output_state} = FeedResourceUrls.handle_demand(5, state)
    assert 2 == output_state.demand
  end

  # --------- HELPERS ------------

  defp stub_state(urls \\ []) do
    MockRepository.set(urls)
    %{
      url_repository: MockRepository,
      buffer: [],
      demand: 0,
    }
  end
end
