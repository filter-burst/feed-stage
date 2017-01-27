



# defmodule FeedStage.AllArticlesTest do
#   use ExUnit.Case
#
#   test "with no available urls, no events are emmitted" do
#     state = %{url_repository: MockUrlRepository}
#     assert {:noreply, [], _} = FeedStage.AllArticles.handle_demand(10, state)
#   end
#
#   test "with one url, returns feed items up to demand number" do
#     state = %{url_repository: TestUrlRepository}
#     assert {:noreply, [], _} = FeedStage.AllArticles.handle_demand(10, state)
#   end
# end
#
#
# class UrlRepository
#   attr_accessor :urls
#
#   def initialize
#     @urls = []
#   end
#
#   def pop_url() do
#     urls.pop
#   end
# end
