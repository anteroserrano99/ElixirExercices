
defmodule Todo.List do

  defstruct  autoId: 1, entries: %{}


  def new, do: %Todo.List{}

  def addEntry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.autoId)
    new_entries = Map.put(todo_list.entries, todo_list.autoId, entry)
    %Todo.List{ todo_list |
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
        %Todo.List{todo_list |
          entries: new_entries
        }
    end

  end

  def deleteEntry(todo_list, id) do
    case Map.fetch(todo_list.entries, id) do
      :error -> todo_list
      {:ok, entry_to_delete} ->
      new_entries = Map.delete(todo_list.entries, id)
      %Todo.List{todo_list |
        entries: new_entries
    }
    end

  end


  def addNewEntries(entries \\ []) do
    Enum.reduce(entries,
    %Todo.List{},
    fn element, acc ->
      addEntry(acc, element)
    end)

  end

  defmodule CsvImporter do
    def openCsv(path) do
      File.stream!(path)
      |> Stream.map(&String.replace(&1, "\n", ""))
      |> Stream.map(&String.split(&1,","))
      |> Stream.map(&String.split(&1,","))
      |> Stream.map(&parseEntry(&1))
      |> Enum.to_list()
      |> Todo.List.addNewEntries()

    end

    defp parseEntry([date, title]) do
      {year, month, day} = String.split(date, "/")
      |> List.to_tuple()

      parsedDate = year <> "-" <> month <> "-" <> day
      {:ok, parsedDate} = Date.from_iso8601(parsedDate)

      %{date: parsedDate, title: title}
    end

  end



end
