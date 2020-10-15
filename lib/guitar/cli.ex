defmodule Guitar.CLI do
  def main(args \\ System.argv()) do
    {options, args, []} = OptionParser.parse_head(args, strict: [
      file: :string,
      today: :string
    ], aliases: [f: :file])

    file = case options do
      [file: file] -> file
      _ -> "log.json"
    end

    today = if today_opt = Keyword.get(options, :today) do
      case Date.from_iso8601(today_opt) do
        {:ok, d} -> d
      end
    else
      NaiveDateTime.local_now() |> NaiveDateTime.to_date()
    end

    {command_fn, command_opts} = case List.first(args) do
      "play" -> {&Guitar.Command.Play.run/3, [strict: []]}
      _ -> {
        &Guitar.Command.List.run/3,
        [
          strict: [count: :integer, full: :boolean],
          aliases: [c: :count, f: :full]
        ]
      }
    end

    {options, [], []} = OptionParser.parse(tl(args), command_opts)

    {:ok, storage} = Task.start_link(Guitar.Storage, :start, [file])

    send(storage, {:list, self()})
    receive do
      {:list, entries} ->
        command_fn.(entries, [ {:today, today} | options], storage)
    end
  end
end
