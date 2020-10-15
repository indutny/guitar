defmodule Guitar.Command.Add do
  @behaviour Guitar.Command

  @impl Guitar.Command
  def run(entries, _options) do
    last = hd entries

    today = NaiveDateTime.local_now() |> NaiveDateTime.to_date()

    { last, current } = if last && last.date === today do
      { hd(tl entries), last }
    else
      { last, %Guitar.Log.Entry{} }
    end

    last = last || %Guitar.Log.Entry{}

    loop({ last, current })
  end

  def loop({ _last, _current }) do
  end
end
