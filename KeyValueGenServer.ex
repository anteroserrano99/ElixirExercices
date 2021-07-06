



defmodule KeyValueStore do
  use GenServer

  @impl GenServer
  def init(_) do
    :timer.send_interval(5000, :cleanup)
    {:ok, %{}}
  end

  def start() do
    GenServer.start(KeyValueStore, nil)
  end

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end


  @impl GenServer
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @impl GenServer
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    IO.puts( "Performing cleanup")
    {:noreply, state}
  end




end

defmodule TestModule do

  def test_key_value() do
    {:ok, pid} = KeyValueStore.start()
    KeyValueStore.put(pid, :key, :value)
    KeyValueStore.get(pid, :key)

  end

end
