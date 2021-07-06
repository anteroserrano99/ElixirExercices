defmodule TodoCacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache_server} = Todo.Cache.start()
    antero_pid = Todo.Cache.server_process(cache_server, "Antero")

    assert antero_pid != Todo.Cache.server_process(cache_server, "Bob")
    assert antero_pid == Todo.Cache.server_process(cache_server, "Antero")

  end

  test "todo_operation" do
    {:ok, cache_server} = Todo.Cache.start()
    antero_pid = Todo.Cache.server_process(cache_server, "Antero")

    Todo.Server.add_entry(antero_pid, %{date: ~D[2021-12-12], title: "works"})
    entries = Todo.Server.entries(antero_pid)

    assert %Todo.List{autoId: 2, entries: %{1 => %{date: ~D[2021-12-12], title: "works"}}} = entries
  end

end
