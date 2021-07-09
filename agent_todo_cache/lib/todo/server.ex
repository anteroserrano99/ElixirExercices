defmodule Todo.Server do
  use Agent, restart: :temporary

  def start_link(name) do

    Agent.start(
      fn ->
        IO.puts("Starting todo server #{name}")
        {name, Todo.Database.get(name) || Todo.List.new()}
      end,
      name: via_tuple(name)
    )
  end

  def add_entry(pid, new_entry) do
    Agent.cast(pid, fn {name, todo_list}->
      new_list = Todo.List.addEntry(todo_list, new_entry)
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)
  end


  def update_entry(pid, key, update_function) do
    Agent.cast(pid, fn {name, todo_list}->
      new_list = Todo.List.updateEntry(todo_list, key, update_function)
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)

  end


  def delete_entry(pid, key) do
    Agent.cast(pid, fn {name, todo_list}->
    new_list = Todo.List.deleteEntry(todo_list, key)
    Todo.Database.store(name, new_list)
    {name, new_list}
    end)
  end

  def entries(pid) do
    Agent.get(
      pid,
      fn {name, _todo_list} -> Todo.Database.get(name)
    end)
  end


  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end

end
