defmodule AOC.CLI.Command do
  @callback run(argv) :: message when argv: [String.t()], message: String.t()

  @callback usage() :: String.t()

  def run([]), do: __MODULE__.Help.run([])

  def run([command | argv]) do
    case command do
      "bootstrap" -> __MODULE__.Bootstrap.run(argv)
      "configure" -> __MODULE__.Configure.run(argv)
      _ -> __MODULE__.Help.run(argv)
    end
  end
end
