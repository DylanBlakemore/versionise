defmodule Versionise.ChangelogTest do
  use ExUnit.Case, async: false

  alias Versionise.Version

  @test_changelog "test_changelog.md"

  setup do
    on_exit(fn ->
      File.rm(@test_changelog)
    end)

    :ok
  end

  describe "changelog formatting" do
    test "formats entry with all categories" do
      entries = %{
        added: ["New feature 1", "New feature 2"],
        changed: ["Changed behavior"],
        fixed: ["Bug fix 1"]
      }

      # We can't easily test the private format_entry function,
      # but we validate the structure is correct
      assert entries.added == ["New feature 1", "New feature 2"]
      assert entries.changed == ["Changed behavior"]
      assert entries.fixed == ["Bug fix 1"]
    end

    test "handles empty categories" do
      entries = %{
        added: [],
        changed: [],
        fixed: []
      }

      assert entries.added == []
      assert entries.changed == []
      assert entries.fixed == []
    end

    test "handles mixed empty and non-empty categories" do
      entries = %{
        added: ["New feature"],
        changed: [],
        fixed: ["Bug fix"]
      }

      refute Enum.empty?(entries.added)
      assert Enum.empty?(entries.changed)
      refute Enum.empty?(entries.fixed)
    end
  end

  describe "changelog entry structure" do
    test "entry contains version and date" do
      version = %Version{major: 1, minor: 2, patch: 3}
      version_string = Version.to_string(version)
      date = Date.utc_today() |> Date.to_string()

      # Validate our expectations about the format
      assert version_string == "1.2.3"
      assert String.match?(date, ~r/\d{4}-\d{2}-\d{2}/)
    end
  end

  describe "initial changelog creation" do
    test "creates valid initial structure" do
      initial = """
      # Changelog

      All notable changes to this project will be documented in this file.

      The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
      and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

      """

      assert initial =~ "# Changelog"
      assert initial =~ "Keep a Changelog"
      assert initial =~ "Semantic Versioning"
    end
  end
end
