defmodule TodoServer do


  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.new()
      loop(callback_module, initial_state)
  end)
  end

  ### SERVER HANDLING LOOP CAST AND CALL ###
  defp loop(callback_module, state) do
    new_state = receive do
      {:call, message, caller} ->
        {response, new_state} = callback_module.handle_call(message, state)
         send(caller, {:response, response})
         new_state
      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
    end

    loop(callback_module, new_state)
  end

  ### SYNCHRONOUS CALL ###
  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} ->
        IO.puts("Success")
        IO.puts(inspect(response))

      _ ->
        IO.puts("failure")
    end


  end

  ### ASYNCHRONOUS CALL WITHOUT RESPONSE ###
  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end


  ### SERVER INTERFACE ###
  def retrieve(server_pid) do
    TodoServer.call(server_pid,{:retrieve, self()})
  end

  def add_entry(server_pid, new_entry) do
    TodoServer.cast(server_pid, {:add_entry, new_entry})

  end

  def update_entry(server_pid, id, update_function) do
    TodoServer.cast(server_pid, {:update_entry, id, update_function})
  end

  def delete_entry(server_pid, id) do
    TodoServer.cast(server_pid, {:delete_entry, id})

  end



end



defmodule TodoList do

  defstruct  autoId: 1, entries: %{}

  ### SERVER HANDLING ###
  def start() do
    TodoServer.start(TodoList)
  end

  def handle_cast({:delete_entry, id},todo_list) do
    TodoList.deleteEntry(todo_list, id)
  end

  def handle_cast({:update_entry, id, update_funciton},todo_list) do
    TodoList.updateEntry(todo_list, id, update_funciton)
  end

  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.addEntry(todo_list, new_entry)
  end

  def handle_call({:retrieve, caller}, todo_list) do
    send(caller, {:response, todo_list})
  end


  ### INTERFACE IMPLEMENTATION ###
  def new, do: %TodoList{}

  def addEntry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.autoId)
    new_entries = Map.put(todo_list.entries, todo_list.autoId, entry)
    %TodoList{ todo_list |
      entries: new_entries,
      autoId: todo_list.autoId + 1
  }


  end

  def updateEntry(todo_list, id, updateFunction) do
    case Map.fetch(todo_list.entries, id) do

      :error -> todo_list

      {:ok, old_entry} ->
        new_entry = updateFunction.(old_entry)
        new_entries = Map.put(todo_list.entries, id, new_entry)
        %TodoList{todo_list |
          entries: new_entries
        }
    end

  end

  def deleteEntry(todo_list, id) do
    case Map.fetch(todo_list.entries, id) do
      :error -> todo_list
      {:ok, entry_to_delete} ->
      new_entries = Map.delete(todo_list.entries, id)
      %TodoList{todo_list |
        entries: new_entries
    }
    end

  end


  def addNewEntries(entries \\ []) do
    Enum.reduce(entries,
    %TodoList{},
    fn element, acc ->
      addEntry(acc, element)
    end)

  end


end


### TESTING MODULE

defmodule TestingModule do

  def test_server_add() do

    todo_list = generate_test_data()

    server_pid = TodoServer.start(TodoList)

    TodoServer.add_entry(server_pid,todo_list.entries[1])
    TodoServer.add_entry(server_pid, todo_list.entries[2])
    TodoServer.add_entry(server_pid,todo_list.entries[3])
    TodoServer.update_entry(server_pid, 2, &Map.put(&1, :title, "you are free today"))
    TodoServer.delete_entry(server_pid, 1)
    TodoServer.retrieve(server_pid)



#    pid = TodoServer.start()
#    todo_list = generate_test_data()
#    caller = self()
#
#    send(pid, {:add_entry, todo_list.entries[1]})
#    send(pid, {:add_entry, todo_list.entries[1]})
#    send(pid, {:add_entry, todo_list.entries[1]})
#    send(pid, {:update_entry, 1, &Map.put(&1, :title, "you are free today")})
#    send(pid, {:delete_entry, 3})
#    send(pid, {:retrieve, caller})
#
#    ## wait for the reception of the retrieve proccess message
#    receive do
#      list -> list
#    end


  end


  def generate_test_data() do
    entry1 = %{date: ~D[2021-01-01], title: "theater"}
    entry2 = %{date: ~D[2021-01-02], title: "park"}
    entry3 = %{date: ~D[2021-01-03], title: "cinema"}
    TodoList.new()
    |> TodoList.addEntry(entry1)
    |> TodoList.addEntry(entry2)
    |> TodoList.addEntry(entry3)

  end
end
