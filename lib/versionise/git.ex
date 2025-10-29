defmodule Versionise.Git do
  @moduledoc """
  Handles git operations for versioning.
  """

  alias Versionise.Version

  @doc """
  Stages all changes in the repository.
  """
  @spec stage_all() :: :ok | {:error, String.t()}
  def stage_all do
    run_command(["add", "-A"])
  end

  @doc """
  Creates a commit with the version release message.
  """
  @spec commit(Version.t()) :: :ok | {:error, String.t()}
  def commit(version) do
    version_string = Version.to_string(version)
    message = "Release version #{version_string}"

    run_command(["commit", "-m", message])
  end

  @doc """
  Creates a git tag for the version.
  """
  @spec create_tag(Version.t()) :: :ok | {:error, String.t()}
  def create_tag(version) do
    version_string = Version.to_string(version)
    tag_name = "v#{version_string}"

    run_command(["tag", "-a", tag_name, "-m", "Version #{version_string}"])
  end

  @doc """
  Pushes commits and tags to the remote repository.
  """
  @spec push(String.t()) :: :ok | {:error, String.t()}
  def push(branch) do
    with :ok <- run_command(["push", "origin", branch]) do
      run_command(["push", "origin", "--tags"])
    end
  end

  @doc """
  Checks if the current directory is a git repository.
  """
  @spec git_repo?() :: boolean()
  def git_repo? do
    ["rev-parse", "--git-dir"]
    |> run_command_capture()
    |> command_success?()
  end

  @doc """
  Checks if there are uncommitted changes.
  """
  @spec uncommitted_changes?() :: boolean()
  def uncommitted_changes? do
    case run_command_capture(["status", "--porcelain"]) do
      {:ok, ""} -> false
      {:ok, _output} -> true
      {:error, _reason} -> true
    end
  end

  @spec command_success?({:ok, String.t()} | {:error, String.t()}) :: boolean()
  defp command_success?({:ok, _output}), do: true
  defp command_success?({:error, _reason}), do: false

  @doc """
  Gets the current branch name.
  """
  @spec current_branch() :: {:ok, String.t()} | {:error, String.t()}
  def current_branch do
    run_command_capture(["rev-parse", "--abbrev-ref", "HEAD"])
  end

  @spec run_command([String.t()]) :: :ok | {:error, String.t()}
  defp run_command(args) do
    args
    |> execute_git_command()
    |> handle_command_result()
  end

  @spec execute_git_command([String.t()]) :: {Collectable.t(), non_neg_integer()}
  defp execute_git_command(args) do
    System.cmd("git", args, into: IO.stream(:stdio, :line))
  end

  @spec handle_command_result({Collectable.t(), non_neg_integer()}) ::
          :ok | {:error, String.t()}
  defp handle_command_result({_output, 0}), do: :ok

  defp handle_command_result({_output, code}),
    do: {:error, "Git command failed with code #{code}"}

  @spec run_command_capture([String.t()]) :: {:ok, String.t()} | {:error, String.t()}
  defp run_command_capture(args) do
    args
    |> execute_git_command_capture()
    |> handle_capture_result()
  end

  @spec execute_git_command_capture([String.t()]) :: {String.t(), non_neg_integer()}
  defp execute_git_command_capture(args) do
    System.cmd("git", args, stderr_to_stdout: true)
  end

  @spec handle_capture_result({String.t(), non_neg_integer()}) ::
          {:ok, String.t()} | {:error, String.t()}
  defp handle_capture_result({output, 0}), do: {:ok, String.trim(output)}
  defp handle_capture_result({error, code}), do: {:error, String.trim(error) <> " (code #{code})"}
end
