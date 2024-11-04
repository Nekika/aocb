defmodule Aoc.Problem.Part do
  @enforce_keys [:description, :sample]
  defstruct [:description, :sample]

  @type t() :: %Aoc.Problem.Part{
          description: binary(),
          sample: binary()
        }

  def parse(element) do
    tree = Floki.parse_fragment!(element)

    %Aoc.Problem.Part{
      description: Floki.text(tree, sep: "\n"),
      sample: Floki.find(tree, "code") |> Floki.text()
    }
  end

  def parse_all(document) when is_binary(document) do
    Regex.scan(~r(<article class="day-desc">.+</article>)sU, document)
    |> List.flatten()
    |> Enum.map(&parse/1)
  end
end
