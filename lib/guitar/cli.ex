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
      "add" -> { &add/2, [ strict: [] ] }
      _ -> {
          &list/2,
          [
            strict: [ count: :integer, full: :boolean ],
            aliases: [ c: :count, f: :full ]
          ]
      }
    end

    { options, [], [] } = OptionParser.parse(tl(args), command_opts)

    File.read!(file) |> Jason.decode!() |> Enum.map(fn entry ->
      Guitar.Log.Entry.from_json(entry)
    end) |> command_fn.(options)
  end

  def add(_contents, []) do
  end

  def list(contents, options) do
    entries = if Keyword.get(options, :full, false) do
      contents
    else
      contents |> Enum.take(Keyword.get(options, :count, 1))
    end

    entries
      |> Enum.map(&to_string/1)
      |> Enum.join("\n")
      |> IO.puts
  end
end
