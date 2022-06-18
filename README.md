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

<!-- TaskDoc -->

By default `mix phx_test.new` will generate a new Phoenix project called `phx_test_app` in the `priv/` directory. You can also specify a custom app name and subdirectory with `mix phx_test.new APP_PATH [--sub-directory DIR]`. All other options are passed directly to `mix phx.new`.

## #TODO:
The `mix phx_test.new` task will also inject a `config/config.exs` file and import the newly generated Phoenix project's config. If you are developing a library for other developers, neither the Phoenix project nor any of its config or dependencies will be included with your package as long as you do not include the path to the project in your `package()[:files]` option in `mix.exs`. If you are developing a production application and want to make sure that the Phoenix projects config does not leak into your production environement, simply move the `import_config "../<sub_directory>/<app_name>/config/config.exs"` statement into your desired environement config file (`dev.exs`, `test.exs`, etc.).