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

  @impl true
  def handle_call({:set_coordinates, x, y}, _from, state) do
    state = Map.put(state, :x, x)
    state = Map.put(state, :y, y)
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

      # Send all the neighbours the message
      Enum.each(state[:neighbours], fn pid ->
        GenServer.cast(pid, {:send_message, message})
      end)

      # Send the message to a random neighbour
      # The below code doesn't work as the message is not being distributed to neighbours and everytime a neighbour reaches counter 10, it does not send the message any further.
      # random_neighbour = Enum.random(state[:neighbours])
      # GenServer.cast(random_neighbour, {:send_message, message})

      {:noreply, state}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_call({:initialize_s, s}, _from, state) do
    # Update the state HashMap
    state = Map.put(state, :s, s)
    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:push_sum, s, w}, state) do
    s_current = state[:s]
    w_current = state[:w]

    sw_ratio1 = state[:sw_ratio1]
    sw_ratio2 = state[:sw_ratio2]
    sw_ratio3 = state[:sw_ratio3]

    lookup_factor = :math.pow(10,-10)

    if(sw_ratio3 - sw_ratio2 <= lookup_factor
      && sw_ratio2 - sw_ratio1 <= lookup_factor) do

      s_new = (s_current + s) / 2
      w_new = (w_current + s) / 2

      state = Map.put(state, :s, s_new)
      state = Map.put(state, :w, w_new)

      sw_ratio = s / w
      state = Map.put(state, :sw_ratio1, sw_ratio2)
      state = Map.put(state, :sw_ratio2, sw_ratio3)
      state = Map.put(state, :sw_ratio3, sw_ratio)

      # Send all the neighbours the message
      Enum.each(state[:neighbours], fn pid ->
        GenServer.cast(pid, {:push_sum, s_new, w_new})
      end)


      # Send the message to a random neighbour
      # The below code doesn't work as the message is not being distributed to
      # neighbours and everytime a neighbour reaches counter 10, it does not
      # send the message any further.
      # random_neighbour = Enum.random(state[:neighbours])
      # GenServer.cast(random_neighbour, {:push_sum, s_new, w_new})

      {:noreply, state}
  else
      state = Map.put(state, :is_pushsum_terminated?, true)
      {:noreply, state}
  end

  end
end
