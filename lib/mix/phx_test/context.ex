defmodule Mix.PhxTest.Context do
  @moduledoc false

  defstruct [:sub_directory, :app_name]

  @doc false
  def new(sub_directory, app_name) do
    %__MODULE__{
      sub_directory: sub_directory,
      app_name: app_name
    }
  end
end
