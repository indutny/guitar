defmodule Guitar.Command do
  @type options :: [{atom(), term}]
  @type entries :: [Guitar.Log.Entry]
  @type storage :: pid()

  @callback run(entries(), options(), storage()) :: entries() | nil
end
