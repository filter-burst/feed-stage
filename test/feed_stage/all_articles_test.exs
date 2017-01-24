defmodule FeedStage.AllArticlesTest do
  use ExUnit.Case
  doctest FeedStage.AllArticles

  test "with no available urls, no events are emmitted" do
    {:ok, stage} = GenStage.start_link(FeedStage.AllArticles, :no_repo)

    GenStage.stream([stage])
    |> Stream.each(&IO.inspect/1)
    |> Stream.run()
    assert 1 + 1 == 1
  end
end

# defmodule ProducerConsumerTesting.Doubler do
#   use GenStage
#
#   ### Public API
#
#   def start_link do
#     GenStage.start_link(__MODULE__, nil)
#   end
#
#   ### Callbacks
#   def init(state) do
#     {:producer_consumer, state}
#   end
#
#   def handle_events(events, _from, state) do
#     events = Enum.map(events, & &1 * 2)
#     {:noreply, events, state}
#   end
#
#   # Need to handle this message when the producer shuts down
#   def handle_info({_, {:producer, status}}, state) do
#     GenStage.async_notify(self(), {:producer, status})
#     {:noreply, [], state}
#   end
# end
#
#
# defmodule ProducerConsumerTesting.DoublerTest do
#   use ExUnit.Case, async: false
#
#   alias ProducerConsumerTesting.Doubler
#
#   setup [:start_doubler]
#
#   test "doubles the incoming data", %{doubler: doubler} do
#     {:ok, step_1} = GenStage.from_enumerable([2,4,6,8])
#     GenStage.sync_subscribe(doubler, to: step_1)
#     assert [doubler] |> GenStage.stream() |> Enum.to_list() == [4, 8, 12, 16]
#   end
#
#   defp start_doubler(_) do
#     {:ok, doubler} = Doubler.start_link
#     [doubler: doubler]
#   end
# end
