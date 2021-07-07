defmodule Todo.Database do
  use GenServer
## global variable where the files are located
  @db_folder "./database"

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)
    {{:ok, exector1}, {:ok, exector2}, {:ok, exector3}} = {Todo.DatabaseWorker.start, Todo.DatabaseWorker.start, Todo.DatabaseWorker.start}
    executors = [exector1, exector2, exector3]
    {:ok, executors}
  end


  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)

  end


  def store(key, data) do
    worker = GenServer.call(__MODULE__, {:getWorker, key})
    GenServer.cast(worker, {:store, key, data})
  end

  def get(key) do
    worker = GenServer.call(__MODULE__, {:getWorker, key})
    GenServer.call(worker, {:get, key})
  end

  def handle_call({:getWorker, key}, _, state) do
    return = Enum.at(state, choose_worker(key))
    {:reply, return, state}
  end



  def choose_worker(key) do
    :erlang.phash2(key, 3)
  end


end



defmodule Todo.DatabaseWorker do
  use GenServer

  @db_folder "./database"

  @impl GenServer
  def init(_) do
    {:ok, nil}
  end

  def start() do
    IO.puts("Starting worker")
    GenServer.start(Todo.DatabaseWorker, nil)

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
