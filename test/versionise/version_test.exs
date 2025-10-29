defmodule Versionise.VersionTest do
  use ExUnit.Case, async: true

  alias Versionise.Version

  doctest Versionise.Version

  describe "parse/1" do
    test "parses valid semantic version" do
      assert {:ok, %Version{major: 1, minor: 2, patch: 3}} = Version.parse("1.2.3")
    end

    test "parses version with leading/trailing whitespace" do
      assert {:ok, %Version{major: 1, minor: 2, patch: 3}} = Version.parse("  1.2.3  ")
    end

    test "parses version with zeros" do
      assert {:ok, %Version{major: 0, minor: 0, patch: 0}} = Version.parse("0.0.0")
    end

    test "returns error for invalid format" do
      assert {:error, "Invalid version format. Expected major.minor.patch"} =
               Version.parse("1.2")
    end

    test "returns error for non-numeric values" do
      assert {:error, "Invalid version format. Expected major.minor.patch"} =
               Version.parse("1.2.a")
    end

    test "returns error for version with too many parts" do
      assert {:error, "Invalid version format. Expected major.minor.patch"} =
               Version.parse("1.2.3.4")
    end

    test "returns error for empty string" do
      assert {:error, "Invalid version format. Expected major.minor.patch"} =
               Version.parse("")
    end
  end

  describe "bump/2" do
    test "bumps patch version" do
      version = %Version{major: 1, minor: 2, patch: 3}
      bumped = Version.bump(version, :patch)

      assert bumped == %Version{major: 1, minor: 2, patch: 4}
    end

    test "bumps minor version and resets patch" do
      version = %Version{major: 1, minor: 2, patch: 3}
      bumped = Version.bump(version, :minor)

      assert bumped == %Version{major: 1, minor: 3, patch: 0}
    end

    test "bumps major version and resets minor and patch" do
      version = %Version{major: 1, minor: 2, patch: 3}
      bumped = Version.bump(version, :major)

      assert bumped == %Version{major: 2, minor: 0, patch: 0}
    end

    test "bumps from zero versions" do
      version = %Version{major: 0, minor: 0, patch: 0}

      assert Version.bump(version, :patch) == %Version{major: 0, minor: 0, patch: 1}
      assert Version.bump(version, :minor) == %Version{major: 0, minor: 1, patch: 0}
      assert Version.bump(version, :major) == %Version{major: 1, minor: 0, patch: 0}
    end
  end

  describe "to_string/1" do
    test "converts version struct to string" do
      version = %Version{major: 1, minor: 2, patch: 3}

      assert Version.to_string(version) == "1.2.3"
    end

    test "converts zero version to string" do
      version = %Version{major: 0, minor: 0, patch: 0}

      assert Version.to_string(version) == "0.0.0"
    end

    test "converts large version numbers" do
      version = %Version{major: 10, minor: 20, patch: 30}

      assert Version.to_string(version) == "10.20.30"
    end
  end

  describe "round trip conversion" do
    test "parse and to_string are inverse operations" do
      original = "1.2.3"
      {:ok, version} = Version.parse(original)
      result = Version.to_string(version)

      assert result == original
    end
  end
end
