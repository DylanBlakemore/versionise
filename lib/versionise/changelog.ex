defmodule Versionise.Changelog do
  @moduledoc """
  Handles CHANGELOG.md file operations and formatting.
  """

  alias Versionise.{Prompter, Version}

  @changelog_file "CHANGELOG.md"

  @type changelog_entries :: %{
          added: [String.t()],
          changed: [String.t()],
          fixed: [String.t()]
        }

  @doc """
  Prompts the user to collect changelog entries interactively.
  """
  @spec collect_entries() :: changelog_entries()
  def collect_entries do
    Prompter.section("Changelog Entries")
    Prompter.info("Enter changelog entries (press Enter with empty line to skip)\n")

    %{
      added: collect_category("Added", "New features or functionality"),
      changed: collect_category("Changed", "Changes to existing functionality"),
      fixed: collect_category("Fixed", "Bug fixes")
    }
  end

  @spec collect_category(String.t(), String.t()) :: [String.t()]
  defp collect_category(category, description) do
    Prompter.collect_entries("#{category} (#{description})")
  end

  @doc """
  Updates the CHANGELOG.md file with new version entries.
  """
  @spec update_file(Version.t(), changelog_entries()) :: :ok | {:error, String.t()}
  def update_file(version, entries) do
    changelog_content = format_entry(version, entries)
    existing_content = read_existing_changelog()
    new_content = insert_new_entry(existing_content, changelog_content)

    write_changelog(new_content)
  end

  @spec read_existing_changelog() :: String.t()
  defp read_existing_changelog do
    @changelog_file
    |> File.read()
    |> handle_read_result()
  end

  @spec handle_read_result({:ok, String.t()} | {:error, atom()}) :: String.t()
  defp handle_read_result({:ok, content}), do: content
  defp handle_read_result({:error, :enoent}), do: create_initial_changelog()
  defp handle_read_result({:error, _reason}), do: ""

  @spec create_initial_changelog() :: String.t()
  defp create_initial_changelog do
    """
    # Changelog

    All notable changes to this project will be documented in this file.

    The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
    and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

    """
  end

  @spec insert_new_entry(String.t(), String.t()) :: String.t()
  defp insert_new_entry(existing_content, new_entry) do
    lines = String.split(existing_content, "\n")
    insert_position = find_insert_position(lines)

    lines
    |> List.insert_at(insert_position, new_entry)
    |> Enum.join("\n")
  end

  @spec find_insert_position([String.t()]) :: non_neg_integer()
  defp find_insert_position(lines) do
    lines
    |> Enum.find_index(&String.starts_with?(&1, "## ["))
    |> default_to_end_of_list(lines)
  end

  @spec default_to_end_of_list(non_neg_integer() | nil, [String.t()]) :: non_neg_integer()
  defp default_to_end_of_list(nil, lines), do: length(lines)
  defp default_to_end_of_list(index, _lines), do: index

  @spec format_entry(Version.t(), changelog_entries()) :: String.t()
  defp format_entry(version, entries) do
    version_string = Version.to_string(version)
    date = Date.utc_today() |> Date.to_string()

    sections = build_sections(entries)

    """
    ## [#{version_string}] - #{date}

    #{sections}

    """
  end

  @spec build_sections(changelog_entries()) :: String.t()
  defp build_sections(entries) do
    [
      format_section("Added", entries.added),
      format_section("Changed", entries.changed),
      format_section("Fixed", entries.fixed)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
  end

  @spec format_section(String.t(), [String.t()]) :: String.t()
  defp format_section(_category, []), do: ""

  defp format_section(category, entries) do
    items = Enum.map_join(entries, "\n", &"- #{&1}")
    "### #{category}\n\n#{items}"
  end

  @spec write_changelog(String.t()) :: :ok | {:error, String.t()}
  defp write_changelog(content) do
    @changelog_file
    |> File.write(content)
    |> handle_write_result()
  end

  @spec handle_write_result(:ok | {:error, atom()}) :: :ok | {:error, String.t()}
  defp handle_write_result(:ok), do: :ok

  defp handle_write_result({:error, reason}) do
    {:error, "Failed to write CHANGELOG.md: #{inspect(reason)}"}
  end
end
