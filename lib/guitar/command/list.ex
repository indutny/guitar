defmodule Guitar.Command.List do
  @behaviour Guitar.Command

  @impl Guitar.Command
  def run(entries, options, _storage) do
    last_entries =
      if Keyword.get(options, :full, false) do
        entries
      else
        count = Keyword.get(options, :count, 1)
        entries |> Enum.take(count)
      end

    string_entries =
      last_entries
      |> Enum.map(&to_string/1)
      |> Enum.join("\n")

    IO.puts("""
    # Guitar Practice

    #{string_entries}
    """)
  end
end
