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
      "add" -> { &Guitar.Command.Add.run/2, [ strict: [] ] }
      _ -> {
        &Guitar.Command.List.run/2,
        [
          strict: [ count: :integer, full: :boolean ],
          aliases: [ c: :count, f: :full ]
        ]
      }
    end

    { options, [], [] } = OptionParser.parse(tl(args), command_opts)

    File.read!(file)
    |> Jason.decode!()
    |> Enum.map(&Guitar.Log.Entry.from_json/1)
    |> command_fn.(options)
  end
end
