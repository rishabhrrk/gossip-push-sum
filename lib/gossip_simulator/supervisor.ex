defmodule GossipSimulator.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init({num_nodes, topology}) do

    node_ids = 1..num_nodes    
    topology = GossipSimulator.TopologyBuilder.build(node_ids, topology)

    nodes = Enum.map(topology, fn i ->
      {id, _} = i
      Supervisor.child_spec({GossipSimulator.Node, i}, id: id)
    end)

    Supervisor.init(nodes, strategy: :one_for_one)
  end
end