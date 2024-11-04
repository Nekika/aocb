defmodule AOC.MixProject do
  use Mix.Project

  def project do
    [
      app: :aocb,
      version: "0.1.0",
      elixir: "~> 1.17",
      escript: escript(),
      deps: deps()
    ]
  end

  def escript() do
    [
      main_module: AOC.CLI
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:floki, "~> 0.36"},
      {:req, "~> 0.5"}
    ]
  end
end
