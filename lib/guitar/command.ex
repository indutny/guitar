defmodule Guitar.Command do
  @type options :: [{atom(), term}]
  @type entries :: [Guitar.Log.Entry]

  @callback run(entries(), options()) :: entries() | nil
end
