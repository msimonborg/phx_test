defmodule Mix.Tasks.PhxTest.New do
  @readme "README.md"
          |> File.read!()
          |> String.split("<!-- TaskDoc -->")
          |> Enum.at(1)

  @moduledoc """
  Creates and embeds a new Phoenix project for your dev enviroment.

  #{@readme}
  """

  use Mix.Task

  alias Mix.Tasks.Phx

  @impl true
  def run(argv) do
    Application.ensure_all_started(:phx_test)
    validate_phx_new!()
    argv = parse_opts(argv)
    Phx.New.run(argv)
  end

  defp parse_opts(argv) do
    case OptionParser.parse(argv, strict: [sub_directory: :string]) do
      {[], [path | _], _} ->
        inject_sub_dir("priv", path, argv)

      {[{:sub_directory, dir}], [path | _], _} ->
        inject_sub_dir(dir, path, argv)

      {_, [], _} ->
        parse_opts(["phx_test_app" | argv])
    end
  end

  defp inject_sub_dir(dir, path, argv) do
    argv = argv -- ["--sub-directory", dir, path]
    ["#{dir}/#{path}" | argv]
  end

  defp validate_phx_new! do
    with {:module, Phx.New} <- Code.ensure_loaded(Phx.New),
         true <- function_exported?(Phx.New, :run, 1),
         :ok <- Application.ensure_started(:phx_new),
         {:ok, chars} <- :application.get_key(:phx_new, :vsn),
         phx_new_vsn = List.to_string(chars),
         comp when comp in [:gt, :eq] <- Version.compare(phx_new_vsn, "1.6.0") do
      :ok
    else
      _ -> raise_phx_new_dependency_error!()
    end
  end

  defp raise_phx_new_dependency_error! do
    Mix.raise("""
    phx_test requires phx_new >= 1.6. Please take one of the following steps:

        * Install the latest phx_new archive with `mix archive.install hex phx_new`

        * Add `{:phx_new, "~> 1.6", only: :dev, runtime: false}` to your deps in mix.exs

    """)
  end
end
