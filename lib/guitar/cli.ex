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
        "play" -> &Guitar.Command.Play.run/2
        "add" -> &Guitar.Command.Add.run/2
        _ -> &Guitar.Command.List.run/2
      end

    today =
      if today_opt = options[:today] do
        Date.from_iso8601!(today_opt)
      else
        NaiveDateTime.local_now() |> NaiveDateTime.to_date()
      end

    {:ok, storage} = Guitar.Storage.start_link(options[:file] || "log.json")

    command_fn.(storage, Keyword.merge(options, today: today))

    Guitar.Storage.stop(storage)
  end
end
