defmodule Todo.Database do
  use GenServer
## global variable where the files are located
  @pool_size 3
  @db_folder "./database"

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)

    {:ok, start_workers()}
  end


  def start_link do
    IO.puts("Starting Database")
    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)

  end


  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    worker_key = :erlang.phash2(key, @pool_size) +1
  end


  defp start_workers() do
    for index <- 1..3, into: %{} do
      {:ok, pid} = Todo.DatabaseWorker.start_link({@db_folder, index - 1})
      {index - 1, pid}
    end
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)

  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }

  end


end
