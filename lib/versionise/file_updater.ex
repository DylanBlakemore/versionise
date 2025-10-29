defmodule Versionise.FileUpdater do
  @moduledoc """
  Updates version numbers in project files.
  """

  alias Versionise.Version

  @mix_file "mix.exs"

  @doc """
  Updates the version in mix.exs file.
  """
  @spec update_mix_file(Version.t()) :: :ok | {:error, String.t()}
  def update_mix_file(new_version) do
    version_string = Version.to_string(new_version)

    with {:ok, content} <- File.read(@mix_file),
         updated_content <- update_version_in_content(content, version_string),
         :ok <- File.write(@mix_file, updated_content) do
      :ok
    else
      {:error, :enoent} -> {:error, "mix.exs file not found"}
      {:error, reason} -> {:error, "Failed to update mix.exs: #{inspect(reason)}"}
    end
  end

  @spec update_version_in_content(String.t(), String.t()) :: String.t()
  defp update_version_in_content(content, new_version) do
    content
    |> update_module_attribute_version(new_version)
    |> update_project_version(new_version)
    |> update_source_ref(new_version)
  end

  @spec update_module_attribute_version(String.t(), String.t()) :: String.t()
  defp update_module_attribute_version(content, new_version) do
    Regex.replace(
      ~r/@version\s+"[^"]+"/,
      content,
      "@version \"#{new_version}\""
    )
  end

  @spec update_project_version(String.t(), String.t()) :: String.t()
  defp update_project_version(content, new_version) do
    Regex.replace(
      ~r/version:\s*"[^"]+"/,
      content,
      "version: \"#{new_version}\""
    )
  end

  @spec update_source_ref(String.t(), String.t()) :: String.t()
  defp update_source_ref(content, new_version) do
    Regex.replace(
      ~r/source_ref:\s*"v[^"]+"/,
      content,
      "source_ref: \"v#{new_version}\""
    )
  end

  @doc """
  Reads the current version from mix.exs file.
  """
  @spec read_current_version() :: {:ok, Version.t()} | {:error, String.t()}
  def read_current_version do
    with {:ok, content} <- read_mix_file(),
         {:ok, version_string} <- extract_version(content) do
      Version.parse(version_string)
    end
  end

  @spec read_mix_file() :: {:ok, String.t()} | {:error, String.t()}
  defp read_mix_file do
    @mix_file
    |> File.read()
    |> handle_file_read()
  end

  @spec handle_file_read({:ok, String.t()} | {:error, atom()}) ::
          {:ok, String.t()} | {:error, String.t()}
  defp handle_file_read({:ok, content}), do: {:ok, content}
  defp handle_file_read({:error, :enoent}), do: {:error, "mix.exs file not found"}

  defp handle_file_read({:error, reason}),
    do: {:error, "Failed to read mix.exs: #{inspect(reason)}"}

  @spec extract_version(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  defp extract_version(content) do
    # Try to find @version module attribute first
    module_attr_version = Regex.run(~r/@version\s+"([^"]+)"/, content, capture: :all_but_first)
    # Fall back to version: in project list
    project_version = Regex.run(~r/version:\s*"([^"]+)"/, content, capture: :all_but_first)

    handle_version_match(module_attr_version || project_version)
  end

  @spec handle_version_match([String.t()] | nil) :: {:ok, String.t()} | {:error, String.t()}
  defp handle_version_match([version]), do: {:ok, version}
  defp handle_version_match(nil), do: {:error, "Could not find version in mix.exs"}
end
