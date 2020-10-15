defmodule Guitar.Log.Exercise do
  @enforce_keys [:name, :bpm]
  defstruct [:name, :bpm, :notes, :strings, :slowdown]

  def from_json(%{ "name" => name, "bpm" => bpm } = json) do
    %Guitar.Log.Exercise{
      name: name,
      bpm: bpm,
      notes: json["notes"],
      strings: case json["strings"] do
        "even" -> :even
        "odd" -> :odd
        _ -> nil
      end,
      slowdown: json["slowdown"]
    }
  end
end

defimpl String.Chars, for: Guitar.Log.Exercise do
  def to_string(t) do
    strings = t.strings || "all"
    notes = t.notes && ", _(#{t.notes})_"
    slowdown = t.slowdown && "/#{t.slowdown}"
    "- #{t.name}: #{t.bpm}#{slowdown} bpm, #{strings} strings#{notes}"
  end
end
