defmodule GossipSimulator.Supervisor do
  use Supervisor

  @default_node_state %{counter: 0, neighbours: [], s: nil, w: 1,
        sw_ratio1: nil, sw_ratio2: nil, sw_ratio3: nil,
        is_pushsum_terminated?: false, x: nil, y: nil, z: nil}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(num_nodes) do

    nodes = Enum.map(1..num_nodes, fn i ->
      Supervisor.child_spec({GossipSimulator.Node, @default_node_state}, id: i)
    end)

    Supervisor.init(nodes, strategy: :one_for_one)
  end
end
