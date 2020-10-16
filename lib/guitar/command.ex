defmodule Guitar.Command do
  @type options :: [{atom(), term}]
  @type entries :: [Guitar.Log.Entry]
  @type storage :: Guitar.Storage.t()

  @callback run(storage(), options()) :: entries() | nil
end
