defmodule Todo.Database do
  use GenServer
## global variable where the files are located
  @db_folder "./persist"

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, nil}
  end


  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)

  end


  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl GenServer
  def handle_call({:get, key}, _, state) do
    data = case File.read(file_name(key)) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
    {:reply, data, state}
  end

  @impl GenServer
  def handle_cast({:store, key, value}, state) do
    key
    |> file_name()
    |> File.write!(:erlang.term_to_binary(value))

    {:noreply, state}
  end



  defp file_name(key) do
    Path.join(@db_folder, to_string(key))

  end

end
