require Logger

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

    # Taking approximation for number of nodes to form a perfect square in 2D topologies
    num_nodes = if topology in ["honeycomb", "randhoneycomb"] do
      num_nodes = :math.sqrt(num_nodes)
      |> :math.ceil
      |> :math.pow(2)
      |> Kernel.trunc

      Logger.info "2D topology - rounding number of nodes to #{num_nodes}"

      num_nodes
    else
      num_nodes
    end

    # Taking approximation for number of nodes to form a perfect cube in 3D topologies
    num_nodes = if topology in ["3Dtorus"] do

      num_nodes = :math.pow(num_nodes,1/3)
      |> :math.ceil
      |> :math.pow(3)
      |> Kernel.trunc

      Logger.info "3D topology - rounding number of nodes to #{num_nodes}"

      num_nodes
    else
      num_nodes
    end

    # Start all nodes
    GossipSimulator.Supervisor.start_link(num_nodes)

    # Get all nodes started by the supervisor
    node_pids =
      Supervisor.which_children(GossipSimulator.Supervisor)
      |> Enum.map(fn {_, pid, :worker, [GossipSimulator.Node]} -> pid end)


    # Create the network topology
    network = GossipSimulator.TopologyBuilder.build(node_pids, topology)

    # Set the neighbours of every node
    Enum.each(network, fn {node, neighbours} ->
      GenServer.call(node, {:set_neighbours, neighbours})  # can also call :add_neighbours
    end)

    case algorithm do
      "gossip" ->
        # Pick a random node to start the gossip
        starter_node_pid = Enum.random(node_pids)
        IO.puts "Choosing random node #{inspect starter_node_pid} to send the first message"

        start_time = System.system_time(:millisecond)
        GossipSimulator.Algorithms.Gossip.run(starter_node_pid)

        wait_until_gossip_converged(node_pids)
        end_time = System.system_time(:millisecond)
        IO.puts "Stopping condition reached. Total time: #{end_time - start_time}ms"

      "push-sum" ->
        GossipSimulator.Algorithms.PushSum.initialize(node_pids)

        starter_node_pid = Enum.random(node_pids)
        IO.puts "Choosing random node #{inspect starter_node_pid} as the starter node"

        start_time = System.system_time(:millisecond)
        GossipSimulator.Algorithms.PushSum.run(starter_node_pid)
        wait_until_pushsum_converged(node_pids)
        end_time = System.system_time(:millisecond)
        IO.puts "Stopping condition reached. Total time: #{end_time - start_time}ms"
    end
  end

  def wait_until_gossip_converged(node_pids) do
    counters = Enum.map(node_pids, fn pid ->
      state = GenServer.call(pid, :get_state)
      state[:counter]
    end)

    converged_counters = Enum.filter(counters, fn c -> c >= 1 end)

    unless length(converged_counters) / length(counters) > 0.9 do

      Logger.debug "Converged counters: #{length(converged_counters)}"
      Logger.debug "All counters: #{length(counters)}"

      wait_until_gossip_converged(node_pids)
    end
  end

  def wait_until_pushsum_converged(node_pids) do
    states = Enum.map node_pids, fn pid -> GenServer.call(pid, :get_state) end
    is_terminated? = Enum.map states, fn s -> s[:is_pushsum_terminated?] end

    unless Enum.all?(is_terminated?, fn i -> i end) do
      wait_until_pushsum_converged(node_pids)
    else
      Logger.debug "Push-sum completed. Converged node details:"
      states
      |> Enum.filter(fn i -> i[:is_pushsum_terminated?] end)
      |> Enum.map(fn i -> Logger.debug("#{inspect i}") end)
    end
  end

  defp print_help_msg do
    IO.puts "Usage: mix run gossip_simulator.exs num_nodes topology algorithm"

    IO.puts "\nAvailable topologies:"
    Enum.each @topologies, &(IO.puts("- #{&1}"))

    IO.puts "\nAvailable algorithms:"
    Enum.each @algorithms, &(IO.puts("- #{&1}"))
  end
end
