defmodule Versionise.GitHub do
  @moduledoc """
  Handles GitHub release creation using the gh CLI.
  """

  alias Versionise.{Changelog, Version}

  @doc """
  Checks if the GitHub CLI is installed and available.
  """
  @spec cli_available?() :: boolean()
  def cli_available? do
    System.cmd("which", ["gh"], stderr_to_stdout: true)
    |> command_success?()
  end

  @spec command_success?({String.t(), non_neg_integer()}) :: boolean()
  defp command_success?({_output, 0}), do: true
  defp command_success?(_result), do: false

  @doc """
  Creates a GitHub release for the given version.
  """
  @spec create_release(Version.t(), Changelog.changelog_entries()) ::
          :ok | {:error, String.t()}
  def create_release(version, changelog_entries) do
    version_string = Version.to_string(version)
    tag_name = "v#{version_string}"
    title = "Release #{version_string}"
    notes = format_release_notes(changelog_entries)

    [
      "release",
      "create",
      tag_name,
      "--title",
      title,
      "--notes",
      notes
    ]
    |> execute_gh_command()
    |> handle_result()
  end

  @spec execute_gh_command([String.t()]) :: {String.t(), non_neg_integer()}
  defp execute_gh_command(args) do
    System.cmd("gh", args, stderr_to_stdout: true)
  end

  @spec handle_result({String.t(), non_neg_integer()}) :: :ok | {:error, String.t()}
  defp handle_result({_output, 0}), do: :ok

  defp handle_result({error, _code}) do
    {:error, "Failed to create GitHub release: #{error}"}
  end

  @spec format_release_notes(Changelog.changelog_entries()) :: String.t()
  defp format_release_notes(entries) do
    [
      format_section("Added", entries.added),
      format_section("Changed", entries.changed),
      format_section("Fixed", entries.fixed)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
    |> default_if_empty()
  end

  @spec default_if_empty(String.t()) :: String.t()
  defp default_if_empty(""), do: "No changes documented"
  defp default_if_empty(sections), do: sections

  @spec format_section(String.t(), [String.t()]) :: String.t()
  defp format_section(_category, []), do: ""

  defp format_section(category, entries) do
    items = Enum.map_join(entries, "\n", &"- #{&1}")
    "### #{category}\n\n#{items}"
  end
end
