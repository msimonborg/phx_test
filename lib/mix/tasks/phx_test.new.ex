defmodule Mix.Tasks.PhxTest.New do
  @readme "README.md"
          |> File.read!()
          |> String.split("<!-- ModuleDoc -->")
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
    raise_if_umbrella!(argv)

    {context, argv} = parse_opts(argv)

    Phx.New.run(argv)

    Mix.shell().info([:yellow, "***** From phx_test *****", :reset])

    phx_path = "#{context.sub_directory}/#{context.app_name}/"
    phx_config_path = "../#{phx_path}config/config.exs"

    if File.exists?("config/config.exs") do
      inject_into_existing_config(phx_config_path)
    else
      write_config_file(phx_config_path)
    end

    inject_test_requirements(context)

    deps = inject_deps(context)
    maybe_prompt_to_install_deps(context, deps)

    if context.ecto?, do: ecto_message(phx_path)
  end

  defp inject_into_existing_config(phx_config_path) do
    path = "config/config.exs"
    Mix.shell().info([:green, "* injecting ", :reset, path])

    path
    |> File.read!()
    |> Kernel.<>("\n")
    |> Kernel.<>(import_config(phx_config_path))
    |> then(&File.write!(path, &1))
  end

  defp write_config_file(phx_config_path) do
    File.mkdir("config")

    Mix.Generator.create_file("config/config.exs", """
    # This file is responsible for configuring your application
    # and its dependencies with the aid of the Config module.
    #
    # This configuration file is loaded before any dependency and
    # is restricted to this project.

    # General application configuration
    import Config

    #{String.trim_trailing(import_config(phx_config_path), "\n")}
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
        context = Context.new(dir, path, ecto?(argv), install?(argv))
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

  defp ecto?(argv) do
    case OptionParser.parse(argv, strict: [ecto: :boolean]) do
      {[ecto: false], _, _} -> false
      _ -> true
    end
  end

  defp install?(argv) do
    case OptionParser.parse(argv, strict: [install: :boolean]) do
      {[install: true], _, _} -> true
      _ -> false
    end
  end

  defp raise_if_umbrella!(argv) do
    case OptionParser.parse(argv, strict: [umbrella: :boolean]) do
      {[umbrella: true], _, _} -> raise_umbrella_error!()
      _ -> :ok
    end
  end

  defp raise_umbrella_error! do
    Mix.raise("""
    `mix phx_test.new` does not support the --umbrella option
    """)
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

  defp inject_deps(%{app_name: app_name, sub_directory: sub_directory}) do
    path = "mix.exs"

    deps =
      "      {:#{app_name}, path: \"./#{sub_directory}/#{app_name}\", only: [:test, :dev]}," <>
        "\n      {:phoenix_live_reload, \"~> 1.2\", only: :dev}," <>
        "\n      {:floki, \">= 0.30.0\", only: :test},\n"

    a =
      path
      |> File.read!()
      |> String.split("defp deps")

    b =
      a
      |> Enum.at(1)
      |> String.split("[\n")

    c =
      b
      |> List.replace_at(1, deps <> Enum.at(b, 1))
      |> Enum.join("[\n")

    d =
      a
      |> List.replace_at(1, c)
      |> Enum.join("defp deps")

    Mix.shell().info([:green, "* injecting ", :reset, path])
    File.write!(path, d)
    deps
  end

  defp inject_test_requirements(context) do
    %{app_name: app_name, sub_directory: sub_directory, ecto?: ecto?} = context
    test_dir_path = "#{sub_directory}/#{app_name}/test"

    comment = """

    # Your Phoenix test app's test cases must be explicitly
    # required by your test helper in order to use them in your
    # root project's tests.
    """

    injection =
      comment
      |> maybe_add_ecto_paths(test_dir_path, ecto?)
      |> add_conn_case_path(test_dir_path)

    path = "test/test_helper.exs"
    test_helper_contents = File.read!(path)

    Mix.shell().info([:green, "* injecting ", :reset, path])
    File.write!(path, test_helper_contents <> injection)
  end

  defp maybe_add_ecto_paths(injection, test_dir_path, ecto?) do
    if ecto? do
      injection <>
        "Code.require_file(\"#{test_dir_path}/test_helper.exs\")\n" <>
        "Code.require_file(\"#{test_dir_path}/support/data_case.ex\")\n"
    else
      injection
    end
  end

  defp add_conn_case_path(injection, test_dir_path) do
    injection <> "Code.require_file(\"#{test_dir_path}/support/conn_case.ex\")\n"
  end

  defp maybe_prompt_to_install_deps(context, deps) do
    install? =
      context.install? or
        Mix.shell().yes?(
          "\nAdded new dev and test dependencies to your root project's mix.exs:\n\n" <>
            String.trim_trailing(deps, ",\n") <>
            "\n\nDo you want to install them now?"
        )

    if install? do
      Mix.shell().info([:green, "* running", :reset, " mix deps.get"])
      System.cmd("mix", ["deps.get"])

      Mix.shell().info([:green, "* running", :reset, " mix deps.compile"])
      System.cmd("mix", ["deps.compile"])
    else
      Mix.shell().info("\nRemember to install your dependencies later\n")
    end
  end

  defp ecto_message(phx_path) do
    Mix.shell().info("""

    You must manually create your test database before running your tests:

        $ cd #{phx_path}
        $ MIX_ENV=test mix ecto.create

    Remember to run any future database commands in the test environment. e.g.

        $ mix ecto.migrate
        $ MIX_ENV=test mix ecto.migrate

    These will not be done for you automatically when running `mix test` from your root project directory.
    """)
  end
end
