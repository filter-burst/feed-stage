defmodule FeedStage.Stages.DummyConsumer do
  use GenStage

  def start_link do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  def init(state) do
    {:consumer, state, []}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      IO.puts "EVENT"
      IO.inspect {self(), event, state}
      IO.puts "--------------"
    end

    # As a consumer we never emit events
    {:noreply, [], state}
  end
end
