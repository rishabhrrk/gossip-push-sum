defmodule GossipSimulator.Algorithms.Gossip do
  def run(starter_node_pid) do
    run(starter_node_pid, "Hello, World!")
  end

  def run(starter_node_pid, message) do
    GenServer.cast(starter_node_pid, {:send_message, message})
  end
end
