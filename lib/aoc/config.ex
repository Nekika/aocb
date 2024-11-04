defmodule Aoc.Config do
  @derive Jason.Encoder
  @enforce_keys [:token, :url]
  defstruct [:token, :url]

  @type t() :: %Aoc.Config{
          token: binary(),
          url: binary()
        }

  @type file_options() :: [path: binary()]

  @type validation_error() :: :empty_token | :empty_url

  @defaults %{
    directory: "~/.config/aoc",
    file: "config.json",
    url: "https://adventofcode.com"
  }

  @doc """
  Parses a JSON source into config.

  # Examples

  iex> Aoc.Config.decode(~s({"token":"1234abcd5678efgh","url":"https://adventofcode.com"}))
  {:ok, %Aoc.Config{token: "1234abcd5678efgh", url: "https://adventofcode.com"}}

  iex> Aoc.Config.decode(~s({"token":"malformed json",))
  {:error, :json_invalid}

  iex> Aoc.Config.decode("NON JSON VALUE")
  {:error, :json_invalid}
  """
  @spec decode(iodata()) :: {:ok, t()} | {:error, :json_invalid}
  def decode(json) do
    with {:ok, map} <- decode_json(json) do
      token = Map.get(map, "token", "")
      url = Map.get(map, "url", "")
      {:ok, %Aoc.Config{token: token, url: url}}
    end
  end

  defp decode_json(json) do
    case Jason.decode(json) do
      {:ok, map} -> {:ok, map}
      {:error, _} -> {:error, :json_invalid}
    end
  end

  defp realpath(opts) do
    path =
      opts
      |> Keyword.get(:path, @defaults[:directory])
      |> Path.expand()

    case Path.extname(path) do
      "" -> Path.join(path, @defaults[:file])
      _ -> path
    end
  end

  @doc """
  Creates a new config.

  The `token` argument is used to set the only property that does not have a default value.
  Other properties can still be manually set through the `opts` argument.

  # Examples

  iex> Aoc.Config.new("1234abcd5678efgh")
  {:ok, %Aoc.Config{token: "1234abcd5678efgh", url: "https://adventofcode.com"}}

  iex> Aoc.Config.new("    ")
  {:error, :empty_token}
  """
  @spec new(binary(), Keyword.t()) :: {:ok, t()} | {:error, :empty_token}
  def new(token, opts \\ []) do
    case String.trim(token) do
      "" -> {:error, :empty_token}
      token -> {:ok, new_with_defaults(token, opts)}
    end
  end

  def new_with_defaults(token, opts \\ []) do
    url = Keyword.get(opts, :url, @defaults[:url])
    %Aoc.Config{token: token, url: url}
  end

  @doc """
  Tries to read a config from a file.

  It will try to read from the default location (`~/.config/aoc/config.json`) unless the `path` option is set.

  If the `path` option leads to a directory, the function will try to read the `<path>/config.json` file.
  """
  @spec read(file_options()) :: {:ok, t()} | {:error, :json_invalid} | {:error, File.posix()}
  def read(opts \\ []) do
    path = realpath(opts)

    with {:ok, json} <- File.read(path) do
      decode(json)
    end
  end

  def read!(path) do
    {:ok, config} = read(path)
    config
  end

  @doc """
  Tries to save the JSON encoded config into a file.

  It will try to write into the default location (`~/.config/aoc/config.json`) unless the `path` option is set.

  If the `path` option lead to a directory, the function will try to write into the `<path>/config.json` file.
  """
  @spec save(t(), file_options()) :: :ok | {:error, validation_error()} | {:error, File.posix()}
  def save(%Aoc.Config{} = config, opts \\ []) do
    path = realpath(opts)

    with :ok <- validate(config),
         :ok <- save_directory(path),
         do: save_file(config, path)
  end

  defp save_file(%Aoc.Config{} = config, path) do
    data = Jason.encode!(config)

    File.write(path, data)
  end

  defp save_directory(path) do
    path
    |> Path.dirname()
    |> File.mkdir_p()
  end

  def save!(%Aoc.Config{} = config, path) do
    :ok = save(config, path)
  end

  @doc """
  Checks that the provided config is valid.

  # Examples

  iex> Aoc.Config.validate(%Aoc.Config{token: "1234abcd5678efgh", url: "https://adventofcode.com"})
  :ok

  iex> Aoc.Config.validate(%Aoc.Config{token: "", url: "https://adventofcode.com"})
  {:error, :empty_token}

  iex> Aoc.Config.validate(%Aoc.Config{token: "1234abcd5678efgh", url: ""})
  {:error, :empty_url}
  """
  def validate(%Aoc.Config{} = config) do
    cond do
      config.token == "" -> {:error, :empty_token}
      config.url == "" -> {:error, :empty_url}
      true -> :ok
    end
  end
end
