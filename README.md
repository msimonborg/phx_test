# PhxTest

Quickly embed Phoenix sample apps in your project for library development.

## Problem

In order to build packages for Phoenix applications, it may be necessary to load a running Phoenix project in development and tests. However, when you ship your library you want to be sure that neither the Phoenix test app nor any of its dependencies are leaked into your distribution.

## Solution

It is possible to embed a Phoenix project into a subdirectory of your project as a dev and test dependency, with full access to its modules and dependencies in your tests and dev environment. You can even start the server directly from your root project directory with `mix phx.server` or `iex -S mix phx.server`, just as you would in a normal Phoenix project.

<!-- ModuleDoc -->

## Installation

`phx_test` is avaialble on [hex.pm](https://hex.pm/packages/phx_test). See the official documentation on [hexdocs](https://hexdocs.pm/phx_test).

```elixir
def deps do
  [
    {:phx_test, "~> 0.1.0", only: [:dev, :test]}
  ]
end
```

## Usage

```bash
$ mix phx_test.new # generates /priv/phx_test_app/ (default)
$ mix phx_test.new my_app # generates /priv/my_app/
$ mix phx_test.new my_app --sub-directory sample_apps # generates /sample_apps/my_app/
$ mix phx_test.new --no-ecto --no-dashboard --no-mailer --no-gettext
```

This task wraps `mix phx.new` and adds some conveniences for embedding a sample Phoenix app inside of another project for development and testing purposes. By default `mix phx_test.new` will generate a new Phoenix project called `phx_test_app` in the `priv/` directory. You can also specify a custom app name and subdirectory with `mix phx_test.new APP_PATH [--sub-directory DIR]`. All other options are passed directly to `mix phx.new`, except `--umbrella`, which `mix phx_test.new` does not support.

## Dependencies

Your new Phoenix app will be automatically added as a dev and test dependency, along with a couple others. Here's the full list of dependencies that will be injected into your root project's `mix.exs`:

```elixir
{:phx_test_app, path: "./priv/phx_test_app", only: [:test, :dev]}, # customized for your test app
{:phoenix_live_reload, "~> 1.2", only: :dev},
{:floki, ">= 0.30.0", only: :test}
```

Your new Phoenix app will bring its own dependencies along with it for your dev and test environments. `floki` and `phoenix_live_reload` must be added explicitly, because as dev and test dependencies of your Phoenix project they are not automatically brought into your root project. None of these dependencies will leak into your production environment by default.

## Config

The `mix phx_test.new` task will also create a `config/config.exs` file if it doesn't exist and import the newly generated Phoenix project's config, or inject the import statement into your existing config. This is necessary to properly configure your new Phoenix application so you can run it during development and tests. 

If you are developing a library package distribution, neither the Phoenix project nor any of its config or dependencies will be included with your package as long as you do not include the path to the project in your `package()[:files]` option in `mix.exs`.

If you are developing a production application and want to make sure that the embedded Phoenix project's config does not leak into your production environment, simply move the `import_config "../<sub_directory>/<app_name>/config/config.exs"` statement into your desired environment config file (`dev.exs`, `test.exs`, etc.).

## Ecto

If your new Phoenix app was installed with Ecto (you can exclude Ecto by passing the `--no-ecto` switch to `mix phx_test.new`) then you will have to explicitly run database tasks in the test environment. In a normal Phoenix project `mix test` quietly takes care of this for you, but this will not be the case when running tests in your root project directory. For example:

```bash
$ cd priv/phx_test_app/
$ mix ecto.create
$ MIX_ENV=test mix ecto.create
$ cd ../..
$ mix test
```

# `IEx` and `mix phx.server`

You will be able to start the server for your new Phoenix test app simply by running `mix phx.server` from your root project directory. `iex -S mix phx.server` also works as expected, and all modules from your root project and the Phoenix app will be loaded and available in `IEx` sessions for both development and test environments.

# Test cases

`mix phx_test.new` injects the following code into your `test/test_helper.exs` to explicitly require your new Phoenix app's test modules:

```elixir
# naming is customized for your generated app
Code.require_file("priv/phx_test_app/test/test_helper.exs")
Code.require_file("priv/phx_test_app/test/support/data_case.ex")
Code.require_file("priv/phx_test_app/test/support/conn_case.ex")
```

Now when running tests with your new Phoenix test app, you are able to use the default `ConnCase` and `DataCase` that are included automatically by Phoenix from your root project's tests. For example:

```elixir
# test/root_project/phx_test_app_test.exs

defmodule RootProject.PhxTestAppTest do
  use PhxTestAppWeb.ConnCase

  test "/", %{conn: conn} do
    assert conn
           |> get("/")
           |> html_response(200) =~ "Welcome to Phoenix!"
  end
end
```

Since your Phoenix test app is now a test dependency of your root project, all of your Phoenix test app's modules will be loaded for tests by default.

## Umbrella projects

Creating umbrella test apps is not supported.

## License

[MIT - Copyright (c) 2022 M. Simon Borg](https://github.com/msimonborg/phx_test/blob/main/LICENSE)

<!-- ModuleDoc -->

## Contributing

Pull requests are welcome. I encourage you to open an issue first so we can discuss the idea, and so you can be sure that the work you're proposing isn't already in development.