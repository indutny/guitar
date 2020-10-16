defmodule Guitar.Log.Exercise do
  @enforce_keys [:name, :bpm]
  defstruct [:name, :bpm, :notes, :strings, :slowdown]

  @type exercise :: Guitar.Log.Exercise

  @spec from_json(Map.t()) :: exercise()
  def from_json(%{"name" => name, "bpm" => bpm} = json) do
    %Guitar.Log.Exercise{
      name: name,
      bpm: bpm,
      notes: json["notes"],
      strings:
        case json["strings"] do
          "even" -> :even
          "odd" -> :odd
          _ -> nil
        end,
      slowdown: json["slowdown"]
    }
  end

  @spec to_json(exercise()) :: Map.t()
  def to_json(e) do
    out = %{
      "name" => e.name,
      "bpm" => e.bpm
    }

    out = if e.notes != nil, do: Map.put(out, "notes", e.notes), else: out

    out =
      if e.strings do
        Map.put(out, "strings", to_string(e.strings))
      else
        out
      end

    out = if e.slowdown, do: Map.put(out, "slowdown", e.slowdown), else: out
    out
  end

  @doc """
  Returns exercise with alternative string set (:odd => :even, :even => :odd)
  """
  @spec alternate(exercise()) :: exercise()
  def alternate(e) do
    new_strings =
      case e.strings do
        :even -> :odd
        :odd -> :even
        x -> x
      end

    %Guitar.Log.Exercise{e | strings: new_strings}
  end

  @doc """
  Returns bpm with optional slowdown
  """
  @spec bpm_to_string(exercise()) :: String.t()
  def bpm_to_string(e) do
    slowdown = e.slowdown && "/#{e.slowdown}"
    "#{e.bpm}#{slowdown}"
  end
end

defimpl String.Chars, for: Guitar.Log.Exercise do
  def to_string(t) do
    bpm = Guitar.Log.Exercise.bpm_to_string(t)
    strings = if t.strings, do: ", #{t.strings} strings", else: ""
    notes = t.notes && ", _(#{t.notes})_"
    "- #{t.name}: #{bpm} bpm#{strings}#{notes}"
  end
end
