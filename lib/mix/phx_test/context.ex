defmodule Mix.PhxTest.Context do
  @moduledoc false

  defstruct [:sub_directory, :app_name, :ecto?, :install?]

  @type t :: %__MODULE__{
          sub_directory: String.t(),
          app_name: String.t(),
          ecto?: boolean,
          install?: boolean
        }

  @doc false
  def new(sub_directory, app_name, ecto?, install?) do
    %__MODULE__{
      sub_directory: sub_directory,
      app_name: app_name,
      ecto?: ecto?,
      install?: install?
    }
  end
end
