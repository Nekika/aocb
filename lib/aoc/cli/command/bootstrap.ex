defmodule AOC.CLI.Command.Bootstrap do
  alias AOC.CLI.Command

  @behaviour Command

  @switches [
    all: :boolean,
    config: :string,
    day: :integer,
    year: :integer
  ]

  def run(argv) do
    with {:ok, {path, opts}} <- parse_options(argv),
         {:ok, config} <- read_config(opts),
         :ok = bootstrap(config, path, opts) do
      "OK"
    else
      {:error, reason} -> Atom.to_string(reason)
    end
  end

  defp bootstrap(config, path, opts) do
    for day <- range(opts) do
      problem = Aoc.Problem.fetch(opts[:year], day, config)
      :ok = Aoc.Problem.save(problem, path)
    end

    :ok
  end

  defp parse_options(args) do
    now = DateTime.now!("Etc/UTC")

    defaults = %{
      all: false,
      day: now.day,
      year: now.year
    }

    with {opts, [path], []} <- OptionParser.parse(args, strict: @switches) do
      opts =
        opts
        |> Map.new()
        |> then(&Map.merge(defaults, &1))

      {:ok, {path, opts}}
    else
      _ -> {:error, :invalid_args}
    end
  end

  defp range(%{all: true}), do: 1..24
  defp range(%{day: day}), do: day..day

  defp read_config(%{config: path}), do: Aoc.Config.read(path)
  defp read_config(_opts), do: Aoc.Config.read()

  def usage() do
    """
    Usage:
        aocb bootstrap <path> [options...]

    Available options:

        --all
            Bootstrap the whole event instead of a single day.

        --config <path>
            The path to the config file to use.
            Default to "~/.config/aoc/config.json"

        --day <number>
            The day from which to retrieve the problem.
            Default to today.

        --year <number>
            The year from which to retrieve the problem.
            Default to current year.
    """
  end
end
