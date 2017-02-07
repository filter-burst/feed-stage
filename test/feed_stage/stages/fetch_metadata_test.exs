defmodule FeedStage.Stages.FetchMetadataTest do
  use ExUnit.Case
  alias FeedStage.Stages.FetchMetadata

  test "when site can't be fetched, should not return event" do
    rss_article = %{
      description: "Consequat non sunt sit laborum eiusmod duis adipisicing adipisicing ea nostrud et tempor dolor.",
      image: nil,
      pubdate: DateTime.from_iso8601("2017-02-03T03:22:35+00:00"),
      tags: [],
      title: "Lorem ipsum 2017-02-03T03:46:30+00:00",
      url: "url1"
    }

    blank_result = {:error, nil}

    stub_parser = Stubr.stub!([scrape_article: fn "url1" -> blank_result end])
    assert {:parse_error} = FetchMetadata.fetch_article_metadata(rss_article, stub_parser)
  end

  test "when site can be fetched, merge data in with rss data" do
    rss_article = %{
      description: "Consequat non sunt sit laborum eiusmod duis adipisicing adipisicing ea nostrud et tempor dolor.",
      image: nil,
      pubdate: DateTime.from_iso8601("2017-02-03T03:22:35+00:00"),
      tags: [],
      title: "Lorem ipsum 2017-02-03T03:46:30+00:00",
      url: "url1"
    }

    scrape_article = %Scrape.Article{
      description: "The Russian plane crash in Egypt was not due to technical failures, say French aviation officials, adding that the flight data recorder suggests a \"violent, sudden\" explosion.",
      image: "http://ichef.bbci.co.uk/news/1024/cpsprodpb/A4F2/production/_86562224_86562223.jpg",
      tags: [%{accuracy: 0.7628205128205128, name: "french"}],
      url: "http://www.bbc.com/news/world-europe-34753464"
    }

    expected = %{
      description: "The Russian plane crash in Egypt was not due to technical failures, say French aviation officials, adding that the flight data recorder suggests a \"violent, sudden\" explosion.",
      image: "http://ichef.bbci.co.uk/news/1024/cpsprodpb/A4F2/production/_86562224_86562223.jpg",
      pubdate: DateTime.from_iso8601("2017-02-03T03:22:35+00:00"),
      tags: [%{accuracy: 0.7628205128205128, name: "french"}],
      title: "Lorem ipsum 2017-02-03T03:46:30+00:00",
      url: "http://www.bbc.com/news/world-europe-34753464"
    }

    stub_parser = Stubr.stub!([scrape_article: fn "url1" -> {:ok, scrape_article} end])
    assert {:parsed_ok, result} = FetchMetadata.fetch_article_metadata(rss_article, stub_parser)
    assert expected == result
  end

end
