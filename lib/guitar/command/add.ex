defmodule Guitar.Command.Add do
  @behaviour Guitar.Command

  @impl Guitar.Command
  def run(entries, options, storage) do
    today = options[:today]
    name = options[:name]
    bpm = options[:bpm]
    notes = options[:notes]
    slowdown = options[:slowdown]
    strings = case options[:strings] do
      "odd" -> :odd
      "even" -> :even
      nil -> nil
    end

    if !name do
      raise ArgumentError, message: "--name is a required option"
    end
    if !bpm do
      raise ArgumentError, message: "--bpm is a required option"
    end

    current = Enum.find(entries, &(&1.date == today)) ||
      %Guitar.Log.Entry{date: today}

    is_present = Enum.any?(current.exercises, &(&1.name === name))
    if is_present do
      raise ArgumentError,
        message: "Can't create duplicate exercise with name: #{name}"
    end

    new_exercise = %Guitar.Log.Exercise{
      name: name,
      bpm: bpm,
      notes: notes,
      slowdown: slowdown,
      strings: strings
    }

    send(storage, {:append, today, new_exercise})
  end
end
