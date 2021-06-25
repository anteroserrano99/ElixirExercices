##### Exercices from elixir on action

## Length of a list
defmodule ListExercices do
  def len([]), do: 0
  def len([head | tail]), do: len(tail) + 1
end


## Range between integer numbers
defmodule RangeExercice do

  def range(n1, n2) when is_number(n1) and is_number(n2) do
    cond do
      n1 < n2 -> range(n1, n2, [])
      n1 > n2 -> range(n2, n1, [])
      n1 == n2 -> []
    end

  end

  defp range(n1, n2, list) when n1 > n2, do: list

  defp range(n1, n2, list) do

    list = [n1 | list]

    range(n1+1, n2, list)
  end

end



defmodule Positives do

  def positives(list) do

    positives(list, [])

  end

  defp positives([], acc), do: acc

  defp positives([head | tail], acc) do

    acc =
      if head >= 0 do
        [head | acc]
      else
        acc
      end

    positives(tail, acc)

  end

end



defmodule FileReader do

  def readLines(path) do
    {:ok, string} = File.read(path)

    String.split(string, "\r\n", trim: true)
  end

  def lineNumber(path) do
    readLines(path)
    |>
    ListExercices.len()
  end

  def lineLength(path) do
    readLines(path)
    |> Enum.each(&(IO.puts(String.length(&1))))
  end

  def wordsPerLine(path) do
    readLines(path)
    |> Enum.each(
      &(
        String.split(&1)
        |> ListExercices.len()
        |> IO.puts()
        )
      )
  end

  def largestLine(path) do
    readLines(path)
    |> Enum.filter(&(String.length(&1)> 15))
    |> IO.puts()

  end

  def largeLines(path) do
    readLines(path)
    |> Enum.reduce("", &(compareString(&1, &2)))
    |> IO.puts()

  end

  defp compareString(s1, s2) do

    if String.length(s1) > String.length(s2) do
      s1
    else
      s2
    end
  end

end
