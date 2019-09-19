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

  @impl true
  def handle_cast({:send_message, message}, state) do
    [_ | neighbours] = state
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state}
  end
end