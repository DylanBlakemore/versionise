defmodule Versionise.GitTest do
  use ExUnit.Case, async: true

  alias Versionise.{Git, Version}

  describe "git_repo?/0" do
    test "returns boolean" do
      result = Git.git_repo?()

      assert is_boolean(result)
    end
  end

  describe "uncommitted_changes?/0" do
    test "returns boolean" do
      result = Git.uncommitted_changes?()

      assert is_boolean(result)
    end
  end

  describe "version struct usage" do
    test "can create commit message from version" do
      version = %Version{major: 1, minor: 2, patch: 3}
      version_string = Version.to_string(version)
      message = "Release version #{version_string}"

      assert message == "Release version 1.2.3"
    end

    test "can create tag name from version" do
      version = %Version{major: 1, minor: 2, patch: 3}
      version_string = Version.to_string(version)
      tag_name = "v#{version_string}"

      assert tag_name == "v1.2.3"
    end
  end
end
