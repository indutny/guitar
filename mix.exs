defmodule Guitar.MixProject do
  use Mix.Project

  def project do
    [
      app: :guitar,
      version: "0.1.0",
      elixir: "~> 1.11",
      deps: deps(),
      escript: [main_module: Guitar.CLI]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.1.2"}
    ]
  end
end
