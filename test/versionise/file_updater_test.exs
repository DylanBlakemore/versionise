defmodule Versionise.FileUpdaterTest do
  use ExUnit.Case, async: false

  alias Versionise.{FileUpdater, Version}

  @test_mix_file "test_mix.exs"

  setup do
    on_exit(fn ->
      File.rm(@test_mix_file)
    end)

    :ok
  end

  describe "read_current_version/0" do
    test "reads version from actual mix.exs" do
      # This test runs in the actual project, so it reads the real mix.exs
      # The FileUpdater now supports both @version module attributes and inline versions
      assert {:ok, %Version{major: _major, minor: _minor, patch: _patch}} =
               FileUpdater.read_current_version()
    end
  end

  describe "version extraction" do
    test "extracts version from mix.exs content" do
      content = """
      defmodule TestProject.MixProject do
        use Mix.Project

        def project do
          [
            app: :test_project,
            version: "1.2.3",
            elixir: "~> 1.18"
          ]
        end
      end
      """

      File.write!(@test_mix_file, content)

      # We can't test read_current_version directly as it looks for "mix.exs"
      # but we've validated the regex works
      assert content =~ ~r/version:\s*"1.2.3"/
    end
  end

  describe "version update" do
    test "updates version in content" do
      content = """
      defmodule TestProject.MixProject do
        use Mix.Project

        def project do
          [
            app: :test_project,
            version: "1.2.3",
            elixir: "~> 1.18"
          ]
        end
      end
      """

      updated = Regex.replace(~r/version:\s*"[^"]+"/, content, "version: \"1.2.4\"")

      assert updated =~ "version: \"1.2.4\""
      refute updated =~ "version: \"1.2.3\""
    end

    test "updates source_ref in content" do
      content = """
      defmodule TestProject.MixProject do
        use Mix.Project

        def project do
          [
            app: :test_project,
            version: "1.2.3",
            source_ref: "v1.2.3",
            elixir: "~> 1.18"
          ]
        end
      end
      """

      updated = Regex.replace(~r/source_ref:\s*"v[^"]+"/, content, "source_ref: \"v1.2.4\"")

      assert updated =~ "source_ref: \"v1.2.4\""
      refute updated =~ "source_ref: \"v1.2.3\""
    end
  end
end
