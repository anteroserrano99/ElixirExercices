
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

  defmodule CsvImporter do
    def openCsv(path) do
      File.stream!(path)
      |> Stream.map(&String.replace(&1, "\n", ""))
      |> Stream.map(&String.split(&1,","))
      |> Stream.map(&parseEntry(&1))
      |> Enum.to_list()
      |> TodoList.addNewEntries()

    end

    defp parseEntry([date, title]) do
      {year, month, day} = String.split(date, "/")
      |> List.to_tuple()

      parsedDate = year <> "-" <> month <> "-" <> day
      {:ok, parsedDate} = Date.from_iso8601(parsedDate)

      %{date: parsedDate, title: title}
    end

  end


  defmodule TestingModule do

  def generate_test_data() do
    entry1 = %{date: ~D[2021-01-01], title: "theater"}
    entry2 = %{date: ~D[2021-01-02], title: "park"}
    entry3 = %{date: ~D[2021-01-03], title: "cinema"}
    TodoList.new()
    |> TodoList.addEntry(entry1)
    |> TodoList.addEntry(entry2)
    |> TodoList.addEntry(entry3)

  end

  def update_element_test() do

    todo_list = generate_test_data()
    |> TodoList.updateEntry(1, &Map.put(&1, :date, ~D[2111-01-01]) )
    |> TodoList.updateEntry(2, &Map.put(&1, :title, "you are free today"))
  end

  def delete_test() do
    generate_test_data()
    |> TodoList.deleteEntry(1)
  end

end




end
