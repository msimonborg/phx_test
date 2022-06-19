defmodule PhxTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_test,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :phx_new]
    ]
  end

  defp deps do
    [
      {:phx_test_app, path: "./priv/phx_test_app", only: [:test, :dev]},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:floki, ">= 0.30.0", only: :test},
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
      {:phx_new, "~> 1.6"}
    ]
  end

  defp description do
    """
    Quickly embed Phoenix sample apps in your project for library development
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["m. simon borg"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/msimonborg/phx_test"
      }
    ]
  end

  defp aliases do
    [
      test: ["test", "credo --strict", "format --check-formatted", "docs"]
    ]
  end
end
