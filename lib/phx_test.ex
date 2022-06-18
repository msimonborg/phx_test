defmodule PhxTest do
  @readme "README.md"
          |> File.read!()
          |> String.split("<!-- ModuleDoc -->")
          |> Enum.at(1)

  @moduledoc "#{@readme}"
end
