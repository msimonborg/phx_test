defmodule PhxTestTest do
  use ExUnit.Case
  doctest PhxTest

  test "greets the world" do
    assert PhxTest.hello() == :world
  end
end
