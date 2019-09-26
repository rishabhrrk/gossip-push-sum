defmodule GossipSimulator.Node do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  # Callbacks

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @doc """
  Sets the GenServer's list of neighbours
  """
  @impl true
  def handle_call({:set_neighbours, neighbours}, _from, state) do
    # Update the state HashMap
    state = Map.put(state, :neighbours, neighbours)
    {:reply, :ok, state}
  end

  @doc """
  Adds one neighbour to the current state
  """
  @impl true
  def handle_call({:add_neighbour, neighbour}, _from, state) do
    current_neighbours = Map.fetch(state, :neighbours)
    updated_neighbours = [neighbour | current_neighbours]

    # Update the state HashMap
    state = Map.put(state, :neighbours, updated_neighbours)
    {:reply, :ok, state}
  end

  @doc """
  Adds a list of neighbours to the current state
  """
  @impl true
  def handle_call({:add_neighbours, neighbours}, _from, state) do
    current_neighbours = Map.get(state, :neighbours)
    updated_neighbours = neighbours ++ current_neighbours

    # Update the state HashMap
    state = Map.put(state, :neighbours, updated_neighbours)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:send_message, message}, state) do
    counter = state[:counter]
    # IO.puts "#{inspect self()}: received message, counter = #{counter}"

    if counter < 10 do

      # Update the counter
      state = Map.put(state, :counter, counter + 1)

      # Send the neighbours the message
      Enum.each(state[:neighbours], fn pid ->
        GenServer.cast(pid, {:send_message, message})
      end)

      {:noreply, state}
    else
      {:noreply, state}
    end
  end
end