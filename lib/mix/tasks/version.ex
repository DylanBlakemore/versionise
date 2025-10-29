defmodule Mix.Tasks.Version do
  @shortdoc "Bump version and guide through release process"

  @moduledoc """
  Interactive Mix task for versioning and releasing Elixir packages.

  ## Usage

      mix version patch
      mix version minor
      mix version major

  This task will guide you through:
  1. Bumping the version number
  2. Updating mix.exs
  3. Collecting changelog entries
  4. Running tests (optional)
  5. Creating git commit and tag (optional)
  6. Pushing to remote (optional)
  7. Creating GitHub release (optional)
  """

  use Mix.Task

  alias Versionise.{Changelog, FileUpdater, Git, GitHub, Prompter, Version}

  @impl Mix.Task
  def run(args) do
    args
    |> parse_args()
    |> execute_release()
  end

  @spec parse_args([String.t()]) :: :major | :minor | :patch | :help
  defp parse_args([bump_type]) when bump_type in ["major", "minor", "patch"] do
    String.to_existing_atom(bump_type)
  end

  defp parse_args(_args), do: :help

  @spec execute_release(:major | :minor | :patch | :help) :: :ok
  defp execute_release(:help) do
    show_help()
  end

  defp execute_release(bump_type) do
    perform_release(bump_type)
  end

  @spec perform_release(:major | :minor | :patch) :: :ok
  defp perform_release(bump_type) do
    with {:ok, current_version} <- get_current_version(),
         new_version <- Version.bump(current_version, bump_type),
         true <- confirm_version(current_version, new_version),
         :ok <- update_files(new_version),
         changelog_entries <- collect_changelog(),
         :ok <- Changelog.update_file(new_version, changelog_entries),
         :ok <- maybe_run_tests(),
         :ok <- maybe_git_operations(new_version),
         :ok <- maybe_github_release(new_version, changelog_entries) do
      show_completion_message()
    else
      {:error, reason} -> handle_error(reason)
      false -> handle_abort()
    end
  end

  @spec get_current_version() :: {:ok, Version.t()} | {:error, String.t()}
  defp get_current_version do
    FileUpdater.read_current_version()
  end

  @spec confirm_version(Version.t(), Version.t()) :: boolean()
  defp confirm_version(current_version, new_version) do
    current = Version.to_string(current_version)
    new = Version.to_string(new_version)

    Prompter.info("Current version: #{current}")
    Prompter.info("New version: #{new}")

    Prompter.confirm("Continue with version #{new}?")
  end

  @spec update_files(Version.t()) :: :ok | {:error, String.t()}
  defp update_files(new_version) do
    Prompter.section("Updating Files")

    new_version
    |> FileUpdater.update_mix_file()
    |> handle_file_update()
  end

  @spec handle_file_update(:ok | {:error, String.t()}) :: :ok | {:error, String.t()}
  defp handle_file_update(:ok) do
    Prompter.success("Updated mix.exs")
    :ok
  end

  defp handle_file_update({:error, _reason} = error), do: error

  @spec collect_changelog() :: Changelog.changelog_entries()
  defp collect_changelog do
    Changelog.collect_entries()
  end

  @spec maybe_run_tests() :: :ok | {:error, String.t()}
  defp maybe_run_tests do
    Prompter.section("Running Tests")

    if Prompter.confirm("Run test suite (mix precommit)?") do
      run_tests()
    else
      skip_tests()
    end
  end

  @spec skip_tests() :: :ok
  defp skip_tests do
    Prompter.info("Skipping tests")
    :ok
  end

  @spec run_tests() :: :ok | {:error, String.t()}
  defp run_tests do
    Prompter.info("Running mix precommit...")

    System.cmd("mix", ["precommit"], into: IO.stream(:stdio, :line))
    |> handle_test_result()
  end

  @spec handle_test_result({Collectable.t(), non_neg_integer()}) ::
          :ok | {:error, String.t()}
  defp handle_test_result({_output, 0}) do
    Prompter.success("All tests passed!")
    :ok
  end

  defp handle_test_result({_output, _code}), do: {:error, "Test suite failed"}

  @spec maybe_git_operations(Version.t()) :: :ok | {:error, String.t()}
  defp maybe_git_operations(version) do
    Prompter.section("Git Operations")

    if Git.git_repo?() do
      prompt_git_operations(version)
    else
      skip_git_operations()
    end
  end

  @spec skip_git_operations() :: :ok
  defp skip_git_operations do
    Prompter.info("Not a git repository, skipping git operations")
    :ok
  end

  @spec prompt_git_operations(Version.t()) :: :ok | {:error, String.t()}
  defp prompt_git_operations(version) do
    if Prompter.confirm("Commit changes and create git tag?") do
      perform_git_operations(version)
    else
      skip_git_commit()
    end
  end

  @spec skip_git_commit() :: :ok
  defp skip_git_commit do
    Prompter.info("Skipping git operations")
    :ok
  end

  @spec perform_git_operations(Version.t()) :: :ok | {:error, String.t()}
  defp perform_git_operations(version) do
    with :ok <- stage_changes(),
         :ok <- commit_changes(version),
         :ok <- create_tag(version) do
      maybe_push()
    end
  end

  @spec stage_changes() :: :ok | {:error, String.t()}
  defp stage_changes do
    Prompter.info("Staging changes...")
    Git.stage_all()
  end

  @spec commit_changes(Version.t()) :: :ok | {:error, String.t()}
  defp commit_changes(version) do
    Prompter.info("Committing...")
    Git.commit(version)
  end

  @spec create_tag(Version.t()) :: :ok | {:error, String.t()}
  defp create_tag(version) do
    Prompter.info("Creating tag...")

    version
    |> Git.create_tag()
    |> handle_tag_creation(version)
  end

  @spec handle_tag_creation(:ok | {:error, String.t()}, Version.t()) ::
          :ok | {:error, String.t()}
  defp handle_tag_creation(:ok, version) do
    Prompter.success("Created tag v#{Version.to_string(version)}")
    :ok
  end

  defp handle_tag_creation(error, _version), do: error

  @spec maybe_push() :: :ok | {:error, String.t()}
  defp maybe_push do
    if Prompter.confirm("Push to origin?") do
      push_to_origin()
    else
      skip_push()
    end
  end

  @spec skip_push() :: :ok
  defp skip_push do
    Prompter.info("Skipping push")
    :ok
  end

  @spec push_to_origin() :: :ok | {:error, String.t()}
  defp push_to_origin do
    Prompter.info("Pushing to origin...")

    with {:ok, branch} <- Git.current_branch(),
         :ok <- Git.push(branch) do
      Prompter.success("Pushed to origin")
      :ok
    end
  end

  @spec maybe_github_release(Version.t(), Changelog.changelog_entries()) ::
          :ok | {:error, String.t()}
  defp maybe_github_release(version, changelog_entries) do
    Prompter.section("GitHub Release")

    if GitHub.cli_available?() do
      prompt_github_release(version, changelog_entries)
    else
      skip_github_release()
    end
  end

  @spec skip_github_release() :: :ok
  defp skip_github_release do
    Prompter.info("GitHub CLI (gh) not installed, skipping GitHub release")
    Prompter.info("Install gh from https://cli.github.com/")
    :ok
  end

  @spec prompt_github_release(Version.t(), Changelog.changelog_entries()) ::
          :ok | {:error, String.t()}
  defp prompt_github_release(version, changelog_entries) do
    if Prompter.confirm("Create GitHub release?") do
      create_github_release(version, changelog_entries)
    else
      skip_github_release_creation()
    end
  end

  @spec skip_github_release_creation() :: :ok
  defp skip_github_release_creation do
    Prompter.info("Skipping GitHub release")
    :ok
  end

  @spec create_github_release(Version.t(), Changelog.changelog_entries()) :: :ok
  defp create_github_release(version, changelog_entries) do
    Prompter.info("Creating GitHub release...")

    version
    |> GitHub.create_release(changelog_entries)
    |> handle_github_result()
  end

  @spec handle_github_result(:ok | {:error, String.t()}) :: :ok
  defp handle_github_result(:ok) do
    Prompter.success("GitHub release created!")
    :ok
  end

  defp handle_github_result({:error, reason}) do
    Prompter.error("Failed to create GitHub release: #{reason}")
    Prompter.info("You can create it manually later")
    :ok
  end

  @spec show_completion_message() :: :ok
  defp show_completion_message do
    Prompter.section("Hex Publishing")
    Prompter.info("To publish to Hex.pm, run:")
    Prompter.info("  mix hex.publish")
    Prompter.info("")
    Prompter.success("Release process complete!")
  end

  @spec handle_error(String.t()) :: no_return()
  defp handle_error(reason) do
    Prompter.error("Release failed: #{reason}")
    Mix.raise("Release aborted")
  end

  @spec handle_abort() :: :ok
  defp handle_abort do
    Prompter.info("Release aborted by user")
  end

  @spec show_help() :: :ok
  defp show_help do
    IO.puts("""
    Usage: mix version <bump_type>

    Bump types:
      patch - Bump patch version (0.0.x)
      minor - Bump minor version (0.x.0)
      major - Bump major version (x.0.0)

    Examples:
      mix version patch   # 1.0.0 -> 1.0.1
      mix version minor   # 1.0.0 -> 1.1.0
      mix version major   # 1.0.0 -> 2.0.0
    """)
  end
end
