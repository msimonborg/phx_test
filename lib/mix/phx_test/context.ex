defmodule Mix.PhxTest.Context do
  @moduledoc false

  defstruct [:sub_directory, :app_path]

  @doc false
  def new(sub_directory, app_path) do
    %__MODULE__{
      sub_directory: sub_directory,
      app_path: app_path
    }
  end
end
