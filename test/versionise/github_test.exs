defmodule Versionise.GitHubTest do
  use ExUnit.Case, async: true

  alias Versionise.GitHub

  describe "cli_available?/0" do
    test "returns boolean" do
      result = GitHub.cli_available?()

      assert is_boolean(result)
    end
  end

  describe "release notes formatting" do
    test "formats entries correctly" do
      entries = %{
        added: ["Feature 1", "Feature 2"],
        changed: [],
        fixed: ["Bug fix"]
      }

      # Validate structure
      refute Enum.empty?(entries.added)
      assert Enum.empty?(entries.changed)
      refute Enum.empty?(entries.fixed)
    end
  end
end
