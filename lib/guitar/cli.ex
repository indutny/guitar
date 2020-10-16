defmodule Guitar.CLI do
  def main(args \\ System.argv()) do
    {options, args, []} =
      OptionParser.parse(args,
        strict: [
          # common
          today: :string,
          help: :boolean,

          # list
          full: :boolean,
          count: :integer,

          # add
          name: :string,
          bpm: :integer,
          slowdown: :integer,
          notes: :string,
          strings: :string
        ],
        aliases: [
          h: :help,
          f: :full,
          c: :count
        ]
      )

    if options[:help] do
      IO.puts("""
      Usage:

        Display past logs:
        $ guitar [list] [--full] [--count <num>]

        Start daily routine:
        $ guitar play

        Add a new exercise to today's log:
        $ guitar add --name <str> --bpm <num> [--slowdown <num>] \\
            [--notes <str>] [--strings <even|odd>]

        For any command:
        [--today <yyyy-mm-dd>] can be used to interact with past entries.
        [--file <log.json>] can be used to override default log location.
      """)
      exit(:normal)
    end

    command_fn =
      case List.first(args) do
        "play" -> &Guitar.Command.Play.run/3
        "add" -> &Guitar.Command.Add.run/3
        _ -> &Guitar.Command.List.run/3
      end

    today =
      if today_opt = options[:today] do
        case Date.from_iso8601(today_opt) do
          {:ok, d} -> d
        end
      else
        NaiveDateTime.local_now() |> NaiveDateTime.to_date()
      end

    {:ok, storage} = Task.start_link(Guitar.Storage, :start, [options[:file] || "log.json"])

    send(storage, {:list, self()})

    receive do
      {:list, entries} ->
        command_fn.(entries, [{:today, today} | options], storage)
    end

    send(storage, {:close, self()})

    receive do
      :closed -> nil
    end
  end
end
