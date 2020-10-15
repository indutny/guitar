defmodule Guitar.Log.Entry do
  @enforce_keys [:date, :exercises]
  defstruct [
    :notes,
    date: NaiveDateTime.local_now() |> NaiveDateTime.to_date(),
    exercises: []
  ]

  def from_json(%{ "date" => date, "exercises" => exercises } = json) do
    %Guitar.Log.Entry{
      notes: Map.get(json, "notes"),
      date: Date.from_iso8601!(date),
      exercises: exercises |> Enum.map(&Guitar.Log.Exercise.from_json/1)
    }
  end
end

defimpl String.Chars, for: Guitar.Log.Entry do
  def to_string(t) do
    """
    ### #{Date.to_iso8601(t.date)}

    #{t.exercises |> Enum.map(&String.Chars.to_string/1) |> Enum.join("\n")}
    """
  end
end
