defmodule Guitar.CLI do
  def main(args \\ System.argv()) do
    { options, args, [] } = OptionParser.parse_head(args, strict: [
      file: :string
    ], aliases: [ f: :file ])

    file = case options do
      [ file: file ] -> file
      _ -> "log.json"
    end

    { command_fn, command_opts } = case List.first(args) do
      "add" -> { &add/2, [] }
      _ -> { &list/2, [ full: :boolean ] }
    end

    { options, [], [] } = OptionParser.parse(tl(args), strict: command_opts)

    File.read!(file) |> Jason.decode!() |> Enum.map(fn entry ->
      Guitar.Log.Entry.from_json(entry)
    end) |> command_fn.(options)
  end

  def add(_contents, []) do
  end

  def list(contents, options) do
    is_full = Keyword.get(options, :full, false)
    out = if is_full do
      contents |> Enum.map(&to_string/1) |> Enum.join("\n")
    else
      contents |> List.last |> to_string()
    end
    IO.puts out
  end
end
