defmodule Guitar.Convert do
  def main(args \\ System.argv()) do
    File.read!(hd(args))
    |> String.split("\n", trim: true)
    |> Enum.reduce({nil, []}, fn line, {last_date, acc} ->
      pattern = ~r|#\s*(?<month>\d+)/(?<day>\d+)/(?<year>\d+)|

      case Regex.named_captures(pattern, line) do
        nil ->
          {last_date, [{last_date, line} | acc]}

        %{"month" => m, "day" => d, "year" => y} ->
          {Date.from_iso8601!("20#{y}-#{m}-#{d}"), acc}
      end
    end)
    |> elem(1)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {date, exercises} ->
      parsed_exercises = Enum.map(exercises, &parse_exercise/1)

      %Guitar.Log.Entry{
        date: date,
        exercises: Enum.reverse(parsed_exercises)
      }
    end)
    |> Enum.sort(Guitar.Log.Entry)
    |> Enum.map(&Guitar.Log.Entry.to_json/1)
    |> Jason.encode!(pretty: true)
    |> IO.puts()
  end

  def parse_exercise(ex) do
    pattern =
      ~r|(?<bpm>\d+)\??(?:/\d+)?\s*-\s*(?<name>[^()]+)\s*(?<strings>\([\d-,\s]+\))?\s*(?<notes>\([^()]\))?|

    %{"bpm" => bpm, "name" => name, "strings" => strings, "notes" => notes} =
      Regex.named_captures(pattern, ex)

    bpm = String.to_integer(bpm)

    strings =
      case strings do
        "" -> nil
        "(1, 3, 5, 7)" -> :odd
        "(1-2,3-4,5-6)" -> :odd
        "(1-3,3-5,5-7)" -> :odd
        "(2, 4, 6)" -> :even
        "(2-3,4-5,6-7)" -> :even
        "(2-4,4-6)" -> :even
      end

    notes =
      case notes do
        "" -> nil
        x -> x
      end

    %Guitar.Log.Exercise{
      bpm: bpm,
      name: String.trim(name),
      strings: strings,
      notes: notes
    }
  end
end

Guitar.Convert.main()
