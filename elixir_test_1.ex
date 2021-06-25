################# ENUM MODULE #############

#It returns the value of all the functions from the Enum module
Enum.__info__(:functions) |> Enum.each(fn({function, arity}) -> IO.puts "#{function}/#{arity}" end)

# We test all item from a collection first parameter is the collection second is the fuction that all must return true
Enum.all?(["foo", "bar", "hello"], fn(s) -> String.length(s) == 3 end)

# We test all items from a collection are greater than 1
Enum.all?(["foo", "bar", "hello"], fn(s) -> String.length(s) > 1 end)

# We test if ther is any item in the collectiion wich covers the condition
Enum.any?(["foo", "bar", "hello"], fn(s) -> String.length(s) == 5 end)

# It creates a subArray with the length of the second parameter
Enum.chunk_every([1,2,3,4,5,6], 2)

# It creates a subArray with checking the given condition by the second parameter that is a function
Enum.chunk_by(["one", "two", "three", "four", "five"], fn(x) -> String.length(x) end)

# Execute the given function every n elements that is indicated by the second parameter
Enum.map_every([1, 2, 3, 4, 5, 6, 7, 8], 3, fn x -> x + 1000 end)

# Iterate over a list of values without creating new values
Enum.each(["one", "two", "three"], fn(s) -> IO.puts(s) end)

# Map every item
Enum.map([1, 2, 3, 4], fn(x) -> x + 10 end)

# Find the minimal value
Enum.min([3,2,4,5,1])

# If enum is empty we produce a minimal value to be returned
Enum.min([], fn -> 2 end)

# Find the maximun value
Enum.max([3,2,4,5,1])

# If enum is empty we produce a maximun value to be returned
Enum.max([], fn -> 4 end)

# Filter and return just the pair values
Enum.filter([1,2,3,4,5,6], fn (x) -> rem(x,2) == 0 end)

# Reduce function, it reduces the collection to just one value parameter by applying the given function
Enum.reduce([1, 2, 3], fn(x, acc) -> x + acc end)

# Reduce function, it reduces the collection to just one value, it start with the value of the middle parameter
Enum.reduce([1, 2, 3], 5, fn(x, acc) -> x + acc end)

# Adds all the values that are differnt from the accumulator.
Enum.reduce(["a","b","c"], "1", fn(x,acc)-> x <> acc end)

#Sorts a collection in a descending order (:asc can be used too)
Enum.sort([1,2,3], :desc)

# This function sorts a collection of maps depending the value they have for the given atom :val
Enum.sort([%{:val => 4}, %{:val => 1}], fn(x,y) -> x[:val] > y[:val] end)

# Without the function to sort the order isnt as we could excpet in the example above
Enum.sort([%{:count => 4}, %{:count => 1}])

# Returns a set
Enum.uniq([1, 2, 3, 2, 1, 1, 1, 1, 1])

# Returns a set if the parts
Enum.uniq_by([%{x: 1, y: 1}, %{x: 2, y: 1}, %{x: 3, y: 3}], fn coord -> coord.y end)

# Use of the & operator
Enum.map([1,2,3], fn number -> number + 3 end)
Enum.map([1,2,3], &(&1 + 3))
# ---------
plus_three = &(&1 + 3)
Enum.map([1,2,3], plus_three)



# Using named Functions

defmodule Adding do
  def plus_three(number), do: number + 3
end

Enum.map([1,2,3], fn number -> Adding.plus_three(number) end)
Enum.map([1,2,3], &Adding.plus_three(&1))


################# PATTERN MATCHING #############

# Basic pattern mathching, first we assign the value of x then we compare it
x = 1

1 = x
2 = x

# pattern mathching lists

list = [1, 2, 3]

[1,2,3] = list
[2,2,3] = list

# tail pattern matching
[1 | tail] = list
# _ is like a wildcard for pattern matching
[1 | _] = list

[_ | [2, 3] ] = list


# Matching with tuples
# This matches
{:ok, value} = {:ok, "Successful!"}

# no matching
{:ok, value} = {"hola", "Successful!"}



##############  PIN OPERATOR

# ^ This operator avoids that a value is reAssigned

{x, ^x} = {2, 1}
2 = x

# pin operator map

key = "hello"

%{^key => value} = %{"hello" => "world"}

# this doesnt match becase the value was assigned above
%{^key => value} = %{:hello => "world"}


# This function  works ussing the pinned value, if the value es Hello it will use the first function if it is not, it will use the mutable greeting value function
greeting = "Hello"
greet = fn

  (^greeting, name) -> "Hi #{name}"
  (greeting, name) -> "#{greeting}, #{name}"
end

greet.("Hello", "Sean")
#"Hi Sean"
greet.("Mornin'", "Sean")
#"Mornin, Sean"




#################### CONTROL STRUCTURES


### IF
if String.valid?("Hello") do
   "Valid string!"
   else
  "Invalid string."
  end

#### UNLESS
 unless is_integer("hello") do
 "no an Int"
 end


# PATTERN MATCH MULTIPLE OPTIONS (CASE)
# After the word case we introduce the input for our programm, that is now pattern matched aganist the functions, if it matches it is used, if not it goes to the default case _, _ its a wildCard Character
case {:ok, "Hello World"} do
{:ok, result} -> result
{:error} -> "Uh oh!"
_ -> "Catch all"
end

case :even do
  :odd -> "Odd"
  _ -> "Not Odd"
end

pie = 3.14
case "cherry pie" do
  ^pie -> "Not so tasty"
  pie -> "I bet #{pie} is tasty"
end
#"I bet cherry pie is tasty"


case {1, 2, 3} do
  {1, x, 3} when x > 0 -> "Will match"
    _ -> "Match for everything else"
  end



# CONDITIONAL, When we want to match expressions rather than values

cond do
  2 + 2 == 5 -> "This will not Match"
  2 * 2 == 123 -> "This wont either"
  1 + 1 == 2 -> "But this will"
end



cond do
  7 + 1 == 0 -> "Incorrect"
  true -> "Catch all"
end



############ WITH, Its a way to refactor multiple case with a cleaner expression

# If the map.fetch returns :ok  Value  the value is assigned to first
# Then it tries the same with the second expression for the key :last and if both expressions match it concatenates the variables
user = %{first: "Sean", last: "Callan"}

with {:ok, first} <- Map.fetch(user, :first),
    {:ok, last} <- Map.fetch(user, :last),
    do: last <> ", " <> first

##  REFACTOR A MULTIPLE CASE USING WITH CONDITIONAL

case Repo.insert(changeset) do
  {:ok, user} ->
    case Guardian.encode_and_sign(user, :token, claims) do
      {:ok, token, full_claims} ->
        important_stuff(token, full_claims)

      error ->
        error
    end

  error ->
    error
end


with {:ok, user} <- Repo.insert(changeset),
     {:ok, token, full_claims} <- Guardian.encode_and_sign(user, :token, claims)

     do important_stuff(token, full_claims)
end


################# FUNCTIONS

### assigning an anonymous fucntion

sum = fn (x, y) -> x + y end
sum.(2,3)


#### usising the shorthHand operator

sum = &(&1, + &2)
sum.(2, 3)


## pattern matching with functions

handle_result = fn
  {:ok, result} -> IO.puts("Handling result...")
  {:ok, _} -> IO.puts "This would be never run as previous will be matched beforeHand"
  {:error} -> IO.puts "An error has occured"
end

some_result = 1

handle_result.({:ok, some_result})

handle_result.({:error})




######## NAMED FUNCTIONS

# simple named function
defmodule Greeter do
  def hello(name) do
    "Hello, " <> name
  end

end

Greeter.hello("Sean")

# Get the length of a linkedList using function's pattern matching
defmodule Length do
  def of([]) do
    0
  end

  def of([ _ | tail]) do
    1 + of(tail)
  end

end

Length.of([1,2,3])

### Greet using function the function's name and its arity(number of parametros)
defmodule Greeter2 do

  def hello() do: "Hellom, anonymous perosn"
  def hello(name) do: "hello, " <> name
  def hello(name1, name2) do: "hello #{name1} and #{name2}"
end

Greeter2.hello()
Greeter2.hello("Fred")
Greeter2.hello("Fred", "Jane")



# Pattern matching with the function parameters
defmodule Greeter1 do

  def hello (%{name: person_name}) do
    IO.puts("hello, " <> person_name)
  end

end

fred = %{name: "Fred", age: "95", favorite_color: "Taupe"}

Greeter1.hello(fred)
## no match becase it doesnt have the name atom
Greeter1.hello(%{age: "95", favorite_color: "Taupe"})


# assign entry parameter to a variable
defmodule Greeter2 do
  def hello(%{name: person_name} = person) do
    IO.puts("hello, " <> person_name)
    IO.inspect(person)
  end
end



# defp is used for private variables
defmodule Greeter4 do
  def hello(name), do: phrase() <> name
  defp phrase, do: "Hello, "
end

# this will give an undefined exception
Greeter4.phrase





############################ GUARDS

# You select a function invocation when a condition is met
defmodule Greeter5 do
  def hello(names) when is_list(names) do
    names
    |> Enum.join(", ")
    | hello
  end

  def hello(name) when is_binary(name) do
    phrase() <> name
  end

  defp phrase, do: "Hello, "

end

Greeter5.hello(["Sean", "Steve"])


#### Default arguments

defmodule Greeter6 do

  def hello(name, language_code \\ "en") do
    phrase(language_code) <> name
  end

  defp phrase("es") do: "hola, "
  defp phrase("en") do: "hello, "

end


## combination of guards and default arguments
defmodule Greeter do
  def hello(names, language_code \\ "en")

  def hello(names, language_code) when is_list(names) do
    names
    |> Enum.join(", ")-
    |> hello(language_code)
  end

  def hello(name, language_code) when is_binary(name) do
    phrase(language_code) <> name
  end

  defp phrase("en"), do: "Hello, "
  defp phrase("es"), do: "Hola, "
end

### EXERCICES

# 1. len of a list recursive
list = [1, 2, 3 ,4 ,5]

defmodule ListExercices do
  def len([]), do: 0
  def len([head | tail]), do: len(tail) + 1
end
