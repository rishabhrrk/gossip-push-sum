defmodule GossipSimulator.Algorithms.PushSum do
  def initialize(node_ids) do
    # Set the initial values for s and w of every node
    node_ids
    |> Enum.with_index()
    |> Enum.each(node_ids, fn {node, id} ->
      GenServer.call(node, {:initialize_s, id})
    end)
  end


  def run(starter_node_pid) do
    GenServer.cast(starter_node_pid, {:push_sum, s, w})
  end
end
