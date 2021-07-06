defmodule Todo.Cache do
  use GenServer

  @impl GenServer
  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}
      :error ->
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        {:reply, new_server, Map.put(todo_servers, todo_list_name, new_server) }
    end


  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})

  end


end


defmodule TestingModuleCache do

  def test_cache()do
    {:ok, cache_pid} = Todo.Cache.start()
    server_pid1 = Todo.Cache.server_process(cache_pid, "Antero's list")
    server_pid2 = Todo.Cache.server_process(cache_pid, "John's list")
    list1 = test_server(server_pid1)
    list2 = test_server(server_pid2)
    {list1, list2}

  end


  def test_server(server) do
    Todo.Server.add_entry(server, %{date: ~D[2021-12-12], title: "works"})
    Todo.Server.add_entry(server, %{date: ~D[2021-12-12], title: "works"})
    Todo.Server.add_entry(server, %{date: ~D[2021-12-12], title: "works"})
    Todo.Server.update_entry(server, 1, &Map.put(&1, :title, "you are free today"))
    Todo.Server.delete_entry(server, 2)
    Todo.Server.entries(server)
  end


end
