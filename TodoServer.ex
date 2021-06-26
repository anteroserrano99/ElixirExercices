defmodule TodoServer do

  def start do
    spawn(fn -> loop(TodoList.new())end)
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      message -> process_message(todo_list, message)
    end

    loop(new_todo_list)
  end

  def process_message(todo_list, {:retrieve, caller}) do
    send(caller, todo_list)
  end

  def process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.addEntry(todo_list, new_entry)
  end

  def process_message(todo_list, {:update_entry, id, update_funciton}) do
    TodoList.updateEntry(todo_list, id, update_funciton)
  end

  def process_message(todo_list, {:delete_entry, id}) do
    TodoList.deleteEntry(todo_list, id)
  end



end



defmodule TodoList do

  defstruct  autoId: 1, entries: %{}


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


defmodule TestingModule do

  def test_server_add() do
    pid = TodoServer.start()
    todo_list = generate_test_data()
    caller = self()

    send(pid, {:add_entry, todo_list.entries[1]})
    send(pid, {:add_entry, todo_list.entries[1]})
    send(pid, {:add_entry, todo_list.entries[1]})
    send(pid, {:update_entry, 1, &Map.put(&1, :title, "you are free today")})
    send(pid, {:delete_entry, 3})
    send(pid, {:retrieve, caller})

    ## wait for the reception of the retrieve proccess message
    receive do
      list -> list
    end


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
