defmodule Mix.Tasks.Aoc.Configure do
  use Mix.Task

  @switches [
    path: :string,
    url: :string
  ]

  @impl true
  def run(args) do
    result =
      with {:ok, {token, opts}} <- parse_options(args),
           {:ok, config} <- Aoc.Config.new(token, opts),
           :ok <- save_config(config, opts),
           do: :finished

    case result do
      :finished -> Mix.Shell.IO.info("Finished.")
      {:error, reason} -> Atom.to_string(reason) |> Mix.Shell.IO.error()
    end
  end

  defp parse_options(args) do
    case OptionParser.parse(args, strict: @switches) do
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
end
