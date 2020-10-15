defmodule Guitar.CLI do
  def main(argv \\ System.argv()) do
    { options, args, _invalid } = OptionParser.parse_head(argv, strict: [
      file: :string
    ], aliases: [ f: :file ])

    file = case options do
      [ file: file ] -> file
      _ -> "log.json"
    end

    command_fn = case args do
      _ -> &list/2
    end

    File.read!(file) |> Jason.decode!() |> Enum.map(fn entry ->
      Guitar.Log.Entry.from_json(entry)
    end) |> command_fn.(args)
  end

  def list(contents, argv) do
    { options, _args, _invalid } = OptionParser.parse_head(argv, strict: [
      full: :boolean
    ])

    is_full = case options do
      [ full: true ] -> true
      _ -> false
    end

    contents |> Enum.map(&to_string/1) |> Enum.join("\n") |> IO.puts
  end
end
