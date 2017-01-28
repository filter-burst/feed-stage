defmodule FeedStage.StageHelpers.BuffersSupply do
  defmacro __using__(_params) do
    quote do
      defp retrieve_items_from_buffer(demand, state) do
        {retrieved, remainder} = Enum.split(state.buffer, demand)
        new_demand = state.demand - length(retrieved)
        {retrieved, %{state | buffer: remainder, demand: new_demand}}
      end

      defp add_items_to_buffer(items, state) do
        %{state | buffer: state.buffer ++ items}
      end
    end
  end
end
