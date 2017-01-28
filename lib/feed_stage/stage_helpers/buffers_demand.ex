defmodule FeedStage.StageHelpers.BuffersDemand do
  defmacro __using__(_params) do
    quote do
      defp buffer_demand(demand, state) do
        %{state | demand: state.demand + demand}
      end

      defp reduce_demand_by(demand, state) do
        %{state | demand: state.demand - demand}
      end
    end
  end
end
