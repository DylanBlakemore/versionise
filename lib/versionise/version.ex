defmodule Versionise.Version do
  @moduledoc """
  Handles semantic version parsing and bumping.
  """

  @type t :: %__MODULE__{
          major: non_neg_integer(),
          minor: non_neg_integer(),
          patch: non_neg_integer()
        }

  defstruct [:major, :minor, :patch]

  @doc """
  Parses a version string into a Version struct.

  ## Examples

      iex> Versionise.Version.parse("1.2.3")
      {:ok, %Versionise.Version{major: 1, minor: 2, patch: 3}}

      iex> Versionise.Version.parse("invalid")
      {:error, "Invalid version format. Expected major.minor.patch"}
  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, String.t()}
  def parse(version_string) when is_binary(version_string) do
    version_string
    |> String.trim()
    |> String.split(".")
    |> parse_parts()
  end

  @spec parse_parts([String.t()]) :: {:ok, t()} | {:error, String.t()}
  defp parse_parts([major, minor, patch]) do
    with {major_int, ""} <- Integer.parse(major),
         {minor_int, ""} <- Integer.parse(minor),
         {patch_int, ""} <- Integer.parse(patch) do
      {:ok, %__MODULE__{major: major_int, minor: minor_int, patch: patch_int}}
    else
      _error -> {:error, "Invalid version format. Expected major.minor.patch"}
    end
  end

  defp parse_parts(_parts), do: {:error, "Invalid version format. Expected major.minor.patch"}

  @doc """
  Bumps the version according to the specified bump type.

  ## Examples

      iex> version = %Versionise.Version{major: 1, minor: 2, patch: 3}
      iex> Versionise.Version.bump(version, :patch)
      %Versionise.Version{major: 1, minor: 2, patch: 4}

      iex> version = %Versionise.Version{major: 1, minor: 2, patch: 3}
      iex> Versionise.Version.bump(version, :minor)
      %Versionise.Version{major: 1, minor: 3, patch: 0}

      iex> version = %Versionise.Version{major: 1, minor: 2, patch: 3}
      iex> Versionise.Version.bump(version, :major)
      %Versionise.Version{major: 2, minor: 0, patch: 0}
  """
  @spec bump(t(), :major | :minor | :patch) :: t()
  def bump(%__MODULE__{major: major, minor: minor, patch: patch}, :patch) do
    %__MODULE__{major: major, minor: minor, patch: patch + 1}
  end

  def bump(%__MODULE__{major: major, minor: minor}, :minor) do
    %__MODULE__{major: major, minor: minor + 1, patch: 0}
  end

  def bump(%__MODULE__{major: major}, :major) do
    %__MODULE__{major: major + 1, minor: 0, patch: 0}
  end

  @doc """
  Converts a Version struct to a string.

  ## Examples

      iex> version = %Versionise.Version{major: 1, minor: 2, patch: 3}
      iex> Versionise.Version.to_string(version)
      "1.2.3"
  """
  @spec to_string(t()) :: String.t()
  def to_string(%__MODULE__{major: major, minor: minor, patch: patch}) do
    "#{major}.#{minor}.#{patch}"
  end
end
