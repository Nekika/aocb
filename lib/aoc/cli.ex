defmodule AOC.CLI do
  alias AOC.CLI.Command

  def main(argv) do
    message = Command.run(argv)
    IO.puts(message)
  end
end
