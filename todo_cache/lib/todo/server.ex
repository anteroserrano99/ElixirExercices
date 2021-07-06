defmodule Todo.Server do
  use GenServer

  @impl GenServer
  def init(name) do
    {:ok, {name, Todo.List.new() || Todo.List.new()}}
  end

  def start(name) do
    GenServer.start(Todo.Server, name)
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
  def handle_call({:retrieve}, _, {name, todo_list}) do
    {:reply, Todo.Database.get(name), todo_list}
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.addEntry(todo_list, new_entry)
    IO.puts("entra")
    Todo.Database.store(name, new_list)
    IO.puts("entra")
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:update_entry, id, update_funciton}, {name, todo_list}) do
    new_list = Todo.List.updateEntry(todo_list, id, update_funciton)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl GenServer
  def handle_cast({:delete_entry, id}, {name, todo_list}) do
    new_list = Todo.List.deleteEntry(todo_list, id)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
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
