defmodule Mix.Tasks.Aoc.Bootstrap do
  use Mix.Task

  @requirements ["app.start"]

  @switches [
    all: :boolean,
    config: :string,
    day: :integer,
    year: :integer
  ]

  @impl true
  def run(args) do
    with {:ok, {path, opts}} <- parse_options(args),
         {:ok, config} <- read_config(opts),
         do: bootstrap(config, path, opts)
  end

  defp bootstrap(config, path, opts) do
    for day <- range(opts) do
      problem = Aoc.Problem.fetch(opts[:year], day, config)
      :ok = Aoc.Problem.save(problem, path)
    end
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

  def range(%{all: true}), do: 1..24
  def range(%{day: day}), do: day..day

  defp read_config(%{config: config}), do: Aoc.Config.read(config)
  defp read_config(_opts), do: Aoc.Config.read()
end
