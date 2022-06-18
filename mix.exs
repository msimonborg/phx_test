defmodule PhxTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_test,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps, do: []

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
end
