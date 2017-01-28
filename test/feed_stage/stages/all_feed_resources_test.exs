# defmodule FeedStage.Stages.AllFeedResourcesTest do
#   use ExUnit.Case
#   alias FeedStage.UrlRepository.MockRepository
#   alias FeedStage.Stages.AllFeedResources
#
#   setup do
#     MockRepository.start_link
#   end
#
#   test "with no available urls, no events are emmitted" do
#     state = stub_state()
#     assert {:noreply, [], _} = AllFeedResources.handle_demand(2, state)
#   end
#
#   test "with available urls, parse enough to meet demand" do
#     state = stub_state(%{"url1" => "body1", "url2" => "body2", "url3" => "body3"})
#     assert {:noreply, ["body1", "body2"], _} = AllFeedResources.handle_demand(2, state)
#   end
#
#   test "with insufficient urls to meet demand, buffer demand and return what you have" do
#     state = stub_state(%{"url1" => "body1", "url2" => "body2", "url3" => "body3"})
#
#     assert {:noreply, ["body1", "body2", "body3"], output_state} = AllFeedResources.handle_demand(5, state)
#     assert 2 == output_state.demand
#   end
#
#   # --------- HELPERS ------------
#
#   defp stub_fetcher(url_mappings) do
#     Stubr.stub!([
#       get!: fn url ->
#         body = url_mappings[url]
#         response = %HTTPoison.Response{
#           body: body,
#           headers: [],
#           status_code: 200
#         }
#         {:ok, response}
#       end
#     ])
#   end
#
#   defp stub_state(url_mappings \\ %{}, other_args \\ %{}) do
#     urls = Map.keys(url_mappings)
#     MockRepository.set(urls)
#
#     result = %{
#       url_repository: MockRepository,
#       resource_fetcher: stub_fetcher(url_mappings),
#       buffer: [],
#       demand: 0,
#     }
#     Map.merge(result, Enum.into(other_args, %{}))
#   end
# end
