defmodule Aoc.Problem do
  require EEx

  EEx.function_from_file(:defp, :template, "templates/day.eex", [:problem])

  @enforce_keys [:day, :input, :parts, :year]
  defstruct [:day, :input, :parts, :year]

  @type t() :: %Aoc.Problem{
          day: integer(),
          input: binary(),
          parts: list(Aoc.Problem.Part.t()),
          year: integer()
        }

  @spec fetch(integer(), integer(), Aoc.Config.t()) :: t()
  def fetch(year, day, config) do
    req = prepare(year, day, config)

    %Aoc.Problem{
      day: day,
      input: fetch_input(req),
      parts: fetch_parts(req),
      year: year
    }
  end

  defp prepare(year, day, config) do
    config.url
    |> URI.parse()
    |> URI.merge("/#{year}/day/#{day}")
    |> then(&Req.new(base_url: &1))
    |> Req.Request.put_header("Cookie", "session=#{config.token}")
  end

  defp fetch_input(req) do
    Req.request!(req, url: "/input")
    |> then(fn response -> response.body end)
  end

  defp fetch_parts(req) do
    Req.request!(req)
    |> then(fn response -> response.body end)
    |> Aoc.Problem.Part.parse_all()
  end

  def save(%Aoc.Problem{} = problem, path) do
    basepath = Path.expand(path)

    with :ok <- File.mkdir_p(basepath),
         :ok <- save_input(problem, basepath),
         do: save_script(problem, basepath)
  end

  defp save_input(problem, basepath) do
    basepath
    |> Path.join("day#{problem.day}_input.txt")
    |> File.write(problem.input)
  end

  defp save_script(problem, basepath) do
    basepath
    |> Path.join("day#{problem.day}.exs")
    |> File.write(template(problem))
  end
end
