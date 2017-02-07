defmodule FeedStage.ArticleRepository.InMemory do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
    set_state(MapSet.new)
  end

  def new?(article) do
    state = get_state()
    if MapSet.member?(state, article.url) do
      false
    else
      set_state MapSet.put(state, article.url)
      true
    end
  end

  # ------------ private ------------

  def set_state(state) do
    Agent.update(__MODULE__, fn _state -> state end)
  end

  def get_state() do
    Agent.get(__MODULE__, &(&1))
  end
end
