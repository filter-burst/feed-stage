defmodule FeedStage.UrlRepository.MockRepositoryTest do
  use ExUnit.Case
  alias FeedStage.UrlRepository.MockRepository

  test "has no urls unless set" do
    MockRepository.start_link
    assert MockRepository.pop_url() == nil
  end

  test "returns front url with each pop" do
    MockRepository.start_link
    MockRepository.set(["url1", "url2"])
    assert MockRepository.pop_url() == "url1"
    assert MockRepository.pop_url() == "url2"
    assert MockRepository.pop_url() == nil
  end
end
