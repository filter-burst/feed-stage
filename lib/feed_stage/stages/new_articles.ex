defmodule FeedStage.Stages.NewArticles do
  use GenStage

  def start_link(article_repository) do
    GenStage.start_link(__MODULE__, article_repository, name: __MODULE__)
  end

  def init(article_repository) do
    {:producer_consumer, article_repository}
  end

  def handle_events(feeds, _from, article_repository) do
    output = Enum.filter(feeds, fn(article) -> article_repository.new?(article) end)
    {:noreply, output, article_repository}
  end
end
