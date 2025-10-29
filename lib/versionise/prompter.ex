defmodule Versionise.Prompter do
  @moduledoc """
  Handles interactive prompts and user input.
  """

  @doc """
  Prompts for a yes/no confirmation.
  Defaults to 'yes' if user presses Enter without input.
  """
  @spec confirm(String.t()) :: boolean()
  def confirm(message) do
    "#{message} [Yn] "
    |> IO.gets()
    |> parse_confirmation()
  end

  @spec parse_confirmation(String.t() | :eof) :: boolean()
  defp parse_confirmation(input) when is_binary(input) do
    input
    |> String.trim()
    |> String.downcase()
    |> interpret_confirmation()
  end

  defp parse_confirmation(_input), do: false

  @spec interpret_confirmation(String.t()) :: boolean()
  defp interpret_confirmation(""), do: true
  defp interpret_confirmation("y"), do: true
  defp interpret_confirmation("yes"), do: true
  defp interpret_confirmation(_input), do: false

  @doc """
  Prompts for a single line of text input.
  """
  @spec input(String.t()) :: String.t()
  def input(message) do
    "#{message} "
    |> IO.gets()
    |> parse_input()
  end

  @spec parse_input(String.t() | :eof) :: String.t()
  defp parse_input(input) when is_binary(input), do: String.trim(input)
  defp parse_input(_input), do: ""

  @doc """
  Collects multiple lines of input until user enters an empty line.
  """
  @spec collect_entries(String.t()) :: [String.t()]
  def collect_entries(message) do
    IO.puts(message)
    do_collect_entries([])
  end

  @spec do_collect_entries([String.t()]) :: [String.t()]
  defp do_collect_entries(acc) do
    entry = input("  -")
    collect_or_finish(entry, acc)
  end

  @spec collect_or_finish(String.t(), [String.t()]) :: [String.t()]
  defp collect_or_finish("", acc), do: Enum.reverse(acc)
  defp collect_or_finish(entry, acc), do: do_collect_entries([entry | acc])

  @doc """
  Prints a section header.
  """
  @spec section(String.t()) :: :ok
  def section(title) do
    IO.puts("\n=== #{title} ===")
  end

  @doc """
  Prints a success message with a checkmark.
  """
  @spec success(String.t()) :: :ok
  def success(message) do
    IO.puts("✓ #{message}")
  end

  @doc """
  Prints an error message.
  """
  @spec error(String.t()) :: :ok
  def error(message) do
    IO.puts("✗ #{message}")
  end

  @doc """
  Prints an info message.
  """
  @spec info(String.t()) :: :ok
  def info(message) do
    IO.puts(message)
  end
end
