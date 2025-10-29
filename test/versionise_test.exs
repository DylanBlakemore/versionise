defmodule VersioniseTest do
  use ExUnit.Case, async: true

  doctest Versionise

  test "module exists" do
    assert Code.ensure_loaded?(Versionise)
  end
end
