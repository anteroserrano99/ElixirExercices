defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  @impl GenServer
  def init(name) do
    {:ok, {name, Todo.List.new() || Todo.List.new()}, @expiry_idle_timeout}
  end

  def start_link(name) do
    IO.puts("Starting todo server #{name}")
    GenServer.start_link(Todo.Server, name, name: via_tuple(name))
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end


  def update_entry(pid, key, update_function) do
    GenServer.cast(pid, {:update_entry, key,  update_function})
  end


  def delete_entry(pid, key) do
    GenServer.cast(pid, {:delete_entry, key})
  end

  def entries(pid) do
    GenServer.call(pid, {:retrieve})
  end


  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping Server #{name}")
    {:stop, :normal, {name, todo_list}}

  end

  @impl GenServer
  def handle_call({:retrieve}, _, {name, todo_list}) do
    IO.puts("retrieve")
    IO.inspect(todo_list)
    %Todo.List{autoId: _, entries: entries} = todo_list
    IO.inspect(entries)
    {:reply, entries, todo_list, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.addEntry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:update_entry, id, update_funciton}, {name, todo_list}) do
    new_list = Todo.List.updateEntry(todo_list, id, update_funciton)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

  @impl GenServer
  def handle_cast({:delete_entry, id}, {name, todo_list}) do
    new_list = Todo.List.deleteEntry(todo_list, id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}, @expiry_idle_timeout}
  end

end





defmodule TestingModule do

  def test_server() do
    {:ok, server} = Todo.Server.start()
    Todo.Server.add_entry(server, %{date: ~D[2021-12-12], title: "works"})
    Todo.Server.add_entry(server, %{date: ~D[2021-12-12], title: "works"})
    Todo.Server.add_entry(server, %{date: ~D[2021-12-12], title: "works"})
    Todo.Server.update_entry(server, 1, &Map.put(&1, :title, "you are free today"))
    Todo.Server.delete_entry(server, 2)
    Todo.Server.entries(server)
  end

end
