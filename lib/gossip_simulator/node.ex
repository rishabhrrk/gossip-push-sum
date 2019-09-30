require Logger

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
  def handle_call({:initialize_s, s}, _from, state) do
    # Update the state HashMap
    state = Map.put(state, :s, s)
    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:send_message, message}, state) do
    counter = state[:counter]
    
    Logger.debug "#{inspect self()}: received message, counter = #{counter}"

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
  def handle_cast(:start_push_sum, state) do

    s = state[:s]
    w = state[:w]

    Logger.debug "Gossip.Node #{inspect self()} | Starting push-sum | s = #{s}, w = #{w}"

    s_new = s / 2
    w_new = w / 2

    state = Map.put(state, :s, s_new)
    state = Map.put(state, :w, w_new)

    sw_ratio = s / w
    sw_ratios = state[:sw_ratios]
    state = Map.put(state, :sw_ratios, [sw_ratio] ++ sw_ratios)

    random_neighbour = Enum.random(state[:neighbours])

    GenServer.cast(random_neighbour, {:push_sum, s_new, w_new})

    {:noreply, state}
  end

  @impl true
  def handle_cast({:push_sum, s, w}, state) do

    s_current = state[:s]
    w_current = state[:w]
    past_sw_ratios = state[:past_sw_ratios]

    Logger.debug "Gossip.Node #{inspect self()}
    Received s = #{s}, w = #{w}
    My state s = #{s_current}, w = #{w_current}, sw_ratios = #{inspect past_sw_ratios}"

    termination_difference = 1.0e-10

    state = if length(past_sw_ratios) >= 3 do

      past_sw_ratio_1 = Enum.at(past_sw_ratios, 0)
      past_sw_ratio_2 = Enum.at(past_sw_ratios, 1)
      past_sw_ratio_3 = Enum.at(past_sw_ratios, 2)
      
      if abs(past_sw_ratio_1 - past_sw_ratio_2) < termination_difference &&
        abs(past_sw_ratio_2 - past_sw_ratio_3) < termination_difference do
        Logger.debug "Gossip.Node #{inspect self()}
        Push-sum terminated | Last s/w ratios = #{inspect past_sw_ratios}"
        
        # Return updated state
        Map.put(state, :is_pushsum_terminated?, true)
      else
        Logger.debug "Gossip.Node #{inspect self()}
        Push-sum condition not reached
        Termination difference not achieved"

        # Return state unchanged
        state
      end
    else
      Logger.debug "Gossip.Node #{inspect self()}
      Push-sum condition not reached
      Not enough past S/W ratios: #{inspect past_sw_ratios}"

      # Return state unchanged
      state
    end

    # Update s and w values
    s_new = (s_current + s) / 2
    w_new = (w_current + w) / 2

    # Update the state
    state = Map.put(state, :s, s_new)
    state = Map.put(state, :w, w_new)

    new_sw_ratio = s_current / w_current
    new_sw_ratios = Enum.slice([new_sw_ratio] ++ past_sw_ratios, 0..2)
    state = Map.put(state, :past_sw_ratios, new_sw_ratios)

    Logger.debug "New S/W ratios are #{inspect new_sw_ratios}"

    # Send the message to a random neighbour
    random_neighbour = Enum.random(state[:neighbours])
    GenServer.cast(random_neighbour, {:push_sum, s_new, w_new})

    {:noreply, state}
  end
end
