defmodule FeedStage.UrlRepository.InMemoryTest do
  use ExUnit.Case
  alias FeedStage.UrlRepository.InMemory, as: UrlRepository

  test "has no urls unless set" do
    UrlRepository.start_link
    assert UrlRepository.pop_url() == nil
  end

  test "returns front url with each pop" do
    UrlRepository.start_link
    UrlRepository.set(["url1", "url2"])
    assert UrlRepository.pop_url() == "url1"
    assert UrlRepository.pop_url() == "url2"
    assert UrlRepository.pop_url() == "url1"
  end
end
