defmodule Guitar.Log.Entry do
  @type entry :: Guitar.Log.Entry

  defstruct [
    date: NaiveDateTime.local_now() |> NaiveDateTime.to_date(),
    exercises: []
  ]

  @spec from_json(Map.t()) :: entry()
  def from_json(%{ "date" => date, "exercises" => exercises }) do
    %Guitar.Log.Entry{
      date: Date.from_iso8601!(date),
      exercises: exercises |> Enum.map(&Guitar.Log.Exercise.from_json/1)
    }
  end

  @spec to_json(entry()) :: Map.t()
  def to_json(e) do
    %{
      "date" => Date.to_iso8601(e.date),
      "exercises" => e.exercises |> Enum.map(&Guitar.Log.Exercise.to_json/1)
    }
  end

  @spec compare(entry(), entry()) :: :lt | :gt | :eq
  def compare(a, b) do
    # Descending order
    case Date.compare(a.date, b.date) do
      :lt -> :gt
      :gt -> :lt
      :eq -> :eq
    end
  end
end

defimpl String.Chars, for: Guitar.Log.Entry do
  def to_string(t) do
    """
    ## #{Date.to_iso8601(t.date)}

    #{t.exercises |> Enum.map(&String.Chars.to_string/1) |> Enum.join("\n")}
    """
  end
end
