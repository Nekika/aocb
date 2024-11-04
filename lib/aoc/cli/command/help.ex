defmodule AOC.CLI.Command.Help do
  alias AOC.CLI.Command

  @behaviour Command

  def run(argv) do
    case argv do
      ["bootstrap"] -> Command.Bootstrap.usage()
      ["configure"] -> Command.Configure.usage()
      _ -> usage()
    end
  end

  def usage() do
    """
    A tool to boostrap an Advent of Code Elixir workspace.

    Usage:
      aocb <command> [options...]

    Available commands:

      bootstrap    Creates a workspace
      configure    Configures the environment

    Use "aocb help <command>" for more information about a command.
    """
  end
end
