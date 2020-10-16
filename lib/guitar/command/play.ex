defmodule Guitar.Command.Play do
  alias IO.ANSI, as: A

  @behaviour Guitar.Command

  @impl Guitar.Command
  def run(entries, [today: today], storage) do
    current =
      Enum.find(entries, &(&1.date == today)) ||
        %Guitar.Log.Entry{date: today}

    last =
      Enum.find(entries, fn entry ->
        Date.compare(entry.date, today) === :lt
      end) || %Guitar.Log.Entry{}

    # Find exercises that weren't played yet
    completed =
      current.exercises
      |> Enum.map(& &1.name)
      |> MapSet.new()

    scheduled =
      last.exercises
      |> Enum.filter(&(not MapSet.member?(completed, &1.name)))
      |> Enum.map(&Guitar.Log.Exercise.alternate(&1))

    s = if length(scheduled) != 1, do: "s", else: ""
    IO.puts("Found #{length(scheduled)} exercise#{s} to be played today")

    scheduled
    |> Enum.map(fn ex ->
      case prompt(ex) do
        nil ->
          nil

        completed ->
          send(storage, {:append, today, completed})
      end
    end)

    [A.green(), "All done, good job!", A.reset()]
    |> A.format()
    |> IO.puts()
  end

  def prompt(ex) do
    [A.white(), to_string(ex), A.reset()]
    |> A.format()
    |> IO.puts()

    answer =
      [
        A.blue(),
        "Choose one: ",
        A.reset(),
        "complete(",
        A.green(),
        "c",
        A.reset(),
        "), skip(",
        A.red(),
        "s",
        A.reset(),
        "), or ",
        A.cyan(),
        "bpm [notes]: ",
        A.reset()
      ]
      |> A.format()
      |> IO.gets()
      |> String.trim()

    answer =
      case answer do
        "complete" -> :complete
        "c" -> :complete
        "skip" -> :skip
        "s" -> :skip
        input -> {:modify, input}
      end

    case answer do
      :complete ->
        ex

      :skip ->
        [A.red(), "...skipped", A.reset()]
        |> A.format()
        |> IO.puts()

        nil

      {:modify, input} ->
        try do
          modify(ex, input)
        rescue
          MatchError ->
            IO.puts("Invalid input, please try again")
            prompt(ex)
        end
    end
  end

  def modify(ex, input) do
    pattern = ~r|(?<bpm>\d+)(?:/(?<slowdown>\d+))?\s*(?<notes>.*)?\s*|

    captures = Regex.named_captures(pattern, input)
    %{"bpm" => bpm, "slowdown" => slowdown, "notes" => notes} = captures

    {bpm, ""} = Integer.parse(bpm)

    slowdown =
      case slowdown do
        "" ->
          nil

        x ->
          {slowdown, ""} = Integer.parse(x)
          slowdown
      end

    notes = if notes == "", do: nil, else: notes

    completed = %Guitar.Log.Exercise{
      ex
      | bpm: bpm,
        slowdown: slowdown,
        notes: notes
    }

    [A.green(), "Modified as: ", A.reset(), to_string(completed)]
    |> A.format()
    |> IO.puts()

    completed
  end
end
