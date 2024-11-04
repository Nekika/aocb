defmodule AOC.CLI.Command.Configure do
  alias AOC.CLI.Command

  @behaviour Command

  def run(args) do
    with {:ok, {token, opts}} <- parse_options(args),
         {:ok, config} <- Aoc.Config.new(token, opts),
         :ok <- save_config(config, opts) do
      "OK"
    else
      {:error, reason} -> Atom.to_string(reason)
    end
  end

  defp parse_options(args) do
    case OptionParser.parse(args, strict: [path: :string, url: :string]) do
      {opts, [token], []} -> {:ok, {token, opts}}
      _ -> {:error, :invalid_args}
    end
  end

  defp save_config(config, opts) do
    case Keyword.get(opts, :path) do
      nil -> Aoc.Config.save(config, [])
      path -> Aoc.Config.save(config, path: path)
    end
  end

  def usage() do
    """
    Usage:
        aocb configure <session-token> [options...]

    Available options:

        --path
            The path where to save the configuration file.
            Default to "~/.config/aoc/config.json".

        --url
            The url of the Advent of Code website.
            This is useful when you're using a self hosted event.
            Default to "https://adventofcode.com".
    """
  end
end
