defmodule SimpleRegistry do
use GenServer

def init(_) do
  etsTable = :ets.new(__MODULE__, [:named_table])
  schedule_repair()
  Process.flag(:trap_exit, true)
  {:ok, etsTable}
end


def start_link do
  GenServer.start_link(__MODULE__, nil, name: __MODULE__)
end

def register(key) do
  GenServer.call(__MODULE__, {:register, {key, self()}})
end




def whereis(key) do
  GenServer.call(__MODULE__, {:whereis, {key}})
end

def handle_call({:register, {key, value}}, _, ets_table) do
  response = case :ets.lookup(ets_table, key) do
     [] ->
      {:reply, :ok, ets_table}
    [response] ->
      {:reply, :error, ets_table}

  end
  Process.link(value)
  :ets.insert_new(ets_table, {key, value})
  response

end

def handle_call({:whereis, {key}}, _, ets_table) do
  response = :ets.lookup(ets_table, key)
  {:reply, response[key], ets_table}
end

def handle_info(:repair, ets_table) do
  IO.puts("REPAIR")

  receive do
    {:EXIT, pid, reason} ->
      IO.puts("exit")
      :ets.match_delete(ets_table, {_, pid})
      # code
  end


schedule_repair()
{:noreply, ets_table}
end


defp schedule_repair() do
  Process.send_after(self(), :repair, 5000)

end


end
