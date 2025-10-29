defmodule Versionise.PrompterTest do
  use ExUnit.Case, async: true

  alias Versionise.Prompter

  describe "output functions" do
    test "section/1 formats section header" do
      assert :ok = Prompter.section("Test Section")
    end

    test "success/1 prints success message" do
      assert :ok = Prompter.success("Test success")
    end

    test "error/1 prints error message" do
      assert :ok = Prompter.error("Test error")
    end

    test "info/1 prints info message" do
      assert :ok = Prompter.info("Test info")
    end
  end
end
