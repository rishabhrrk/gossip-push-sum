defmodule GossipSimulator.CLI do

  @topologies ["full", "line", "rand2D", "3Dtorus", "honeycomb", "randhoneycomb"]
  @algorithms ["gossip", "push-sum"]

  def main do
    args = System.argv()

    if length(args) != 3 do
      print_help_msg()
      exit :shutdown
    end

    # TODO try/catch/rescue block here to handle invalid arguments
    num_nodes = args |> Enum.at(0) |> String.to_integer

    topology = Enum.at(args, 1)
    
    unless Enum.member?(@topologies, topology) do
      print_help_msg()
      exit :shutdown
    end

    algorithm = Enum.at(args, 2)

    unless Enum.member?(@algorithms, algorithm) do
      print_help_msg()
      exit :shutdown
    end

    # Start all nodes
    GossipSimulator.Supervisor.start_link({num_nodes, topology})

    # Get all nodes started by the supervisor
    nodes = Supervisor.which_children(GossipSimulator.Supervisor)
    node_pids = Enum.map(nodes, fn {_, pid, :worker, [GossipSimulator.Node]} -> pid end)

    case algorithm do
      "gossip" ->
        
        starter_node = Enum.random(nodes)
        {starter_node_id, starter_node_pid, _, _} = starter_node
        IO.puts "Starting node: Node #{starter_node_id} (#{inspect starter_node_pid})"

        GossipSimulator.Algorithms.Gossip.run(starter_node_pid)
        
        IO.inspect GenServer.call(starter_node_pid, :get_state)
      
      "push-sum" -> GossipSimulator.Algorithms.PushSum.run(node_pids)
    end
  end

  defp print_help_msg do
    IO.puts "Usage: mix run gossip_simulator.exs num_nodes topology algorithm"

    IO.puts "\nAvailable topologies:"
    Enum.each(@topologies, &(IO.puts("- #{&1}")))

    IO.puts "\nAvailable algorithms:"
    Enum.each(@algorithms, &(IO.puts("- #{&1}")))
  end
end
