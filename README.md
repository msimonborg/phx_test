# PhxTest

<!-- ModuleDoc -->

Quickly embed Phoenix sample apps in your project for library development.

## Installation

```elixir
def deps do
  [
    {:phx_test, git: "https://github.com/msimonborg/phx_test", only: [:dev, :test]}
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

By default `mix phx_test.new` will generate a new Phoenix project called `phx_test_app` in the `priv/` directory. You can also specify a custom app name and subdirectory with `mix phx_test.new APP_PATH [--sub-directory DIR]`. All other options are passed directly to `mix phx.new`, except `--umbrella`, which `mix phx_test.new` does not support.

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

If you are developing a library package distrobution, neither the Phoenix project nor any of its config or dependencies will be included with your package as long as you do not include the path to the project in your `package()[:files]` option in `mix.exs`.

If you are developing a production application and want to make sure that the embedded Phoenix project's config does not leak into your production environement, simply move the `import_config "../<sub_directory>/<app_name>/config/config.exs"` statement into your desired environment config file (`dev.exs`, `test.exs`, etc.).

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
<!-- ModuleDoc -->