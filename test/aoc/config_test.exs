defmodule Aoc.ConfigTest do
  use ExUnit.Case, async: true

  doctest(Aoc.Config)

  setup context do
    config = %Aoc.Config{token: "1234abcd5678efgh", url: "https://adventofcode.com"}

    if tmp_dir = context[:tmp_dir] do
      path = tmp_dir |> Path.join("config.json")

      unless Map.has_key?(context, :tmp_dir_empty) do
        data = Jason.encode!(config)
        File.write!(path, data)
      end

      %{config: config, path: path}
    else
      %{config: config}
    end
  end

  @tag :tmp_dir
  test "read", %{config: expected, path: path} do
    assert {:ok, config} = Aoc.Config.read(path: path)
    assert %Aoc.Config{} = config
    assert config == expected
  end

  @tag :tmp_dir
  @tag :tmp_dir_empty
  test "save", %{config: config, path: path} do
    assert File.exists?(path) == false
    assert :ok = Aoc.Config.save(config, path: path)
    assert File.exists?(path)
  end
end
