defmodule Todo.Server do
  use GenServer

  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new()}
  end

  def start() do
    GenServer.start(Todo.Server, nil)
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


  @impl GenServer
  def handle_call({:retrieve}, _, todo_list) do
    {:reply, todo_list, todo_list}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, Todo.List.addEntry(todo_list, new_entry)}
  end

  @impl GenServer
  def handle_cast({:update_entry, id, update_funciton}, todo_list) do
    {:noreply, Todo.List.updateEntry(todo_list, id, update_funciton)}
  end

  @impl GenServer
  def handle_cast({:delete_entry, id}, todo_list) do
    {:noreply, Todo.List.deleteEntry(todo_list, id)}
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
