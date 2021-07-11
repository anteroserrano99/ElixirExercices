defmodule Todo.Database do
## global variable where the files are located
  @pool_size 3
  @db_folder "./database/#{node}"



  def store(key, data) do
    {_results, bad_nodes} =
      :rpc.multicall(
        __MODULE__,
        :store_local,
        [key, data],
        :timer.seconds(5)
      )
      Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))



  end

  def store_local(key, data) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.store(worker_pid, key, data)
      end
    )
  end

  def get(key) do

    :poolboy.transaction(
      __MODULE__,
      fn worker_pid ->
        Todo.DatabaseWorker.get(worker_pid, key)
      end
    )
  end

  def child_spec(_) do
    IO.puts("Starting Database")
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: 3
      ],
      [@db_folder]
    )
  end


end