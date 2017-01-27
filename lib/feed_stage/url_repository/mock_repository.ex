defmodule FeedStage.UrlRepository.MockRepository do
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
    set([])
  end

  def set(urls) do
    Agent.update(__MODULE__, fn _urls -> urls end)
  end

  def urls do
    Agent.get(__MODULE__, &(&1))
  end

  def pop_url() do
    case urls do
      [head | tail] ->
        set(tail)
        head
      [] ->
        nil
    end
  end
end
