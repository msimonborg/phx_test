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

  alias Mix.{PhxTest.Context, Tasks.Phx}

  @impl true
  def run(argv) do
    Application.ensure_all_started(:phx_test)
    validate_phx_new!()

    {context, argv} = parse_opts(argv)

    Phx.New.run(argv)

    phx_config_path = "../#{context.sub_directory}/#{context.app_path}/config/config.exs"

    if File.exists?("config/config.exs") do
      inject_config(phx_config_path)
    else
      write_config(phx_config_path)
    end
  end

  defp inject_config(phx_config_path) do
    path = "config/config.exs"
    Mix.shell().info([:green, "* injecting ", :reset, Path.relative_to_cwd(path)])

    path
    |> File.read!()
    |> Kernel.<>("\n")
    |> Kernel.<>(import_config(phx_config_path))
    |> then(&File.write!(path, &1))
  end

  defp write_config(phx_config_path) do
    File.mkdir("config")

    Mix.Generator.create_file("config/config.exs", """
    # This file is responsible for configuring your application
    # and its dependencies with the aid of the Config module.
    #
    # This configuration file is loaded before any dependency and
    # is restricted to this project.

    # General application configuration
    import Config

    #{import_config(phx_config_path)}
    """)
  end

  defp import_config(phx_config_path) do
    """
    # If you are developing a hex package, this config will not be included
    # with your published library.
    #
    # If your config ships with your library or
    # production application, you may want to move this line to the desired
    # environment config file. e.g. config/dev.exs, config/test.exs
    import_config "#{phx_config_path}"
    """
  end

  defp parse_opts(argv) do
    case OptionParser.parse(argv, strict: [sub_directory: :string]) do
      {[{:sub_directory, dir}], [path | _], _} ->
        context = Context.new(dir, path)
        argv = inject_sub_dir(dir, path, argv)
        {context, argv}

      {[], [_ | _], _} ->
        parse_opts(argv ++ ["--sub-directory", "priv"])

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
