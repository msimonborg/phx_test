defmodule Mix.Tasks.PhxTest.Test do
  @moduledoc false

  alias Mix.Tasks.PhxTest

  @paths ~w(mix.exs mix.lock test/test_helper.exs)

  def run(["--setup"]) do
    unless File.exists?("tmp") and File.exists?("priv") do
      if File.exists?("tmp"), do: File.rm_rf!("tmp")

      File.mkdir!("tmp")
      File.mkdir!("tmp/config")
      File.mkdir!("tmp/test")

      for path <- @paths do
        dest = tmp_path(path)
        File.cp!(path, dest)
      end

      argv = ["--no-dashboard", "--no-gettext", "--no-mailer", "--no-live", "--install"]
      PhxTest.New.run(argv)

      System.cmd("mix", ["compile"])

      File.cd!("priv/phx_test_app", fn ->
        System.cmd("mix", ["ecto.create"])
      end)
    end
  end

  def run(["--teardown"]) do
    if File.exists?("tmp") and File.exists?("priv") do
      for path <- @paths do
        source = tmp_path(path)
        File.cp!(source, path)
      end

      File.rm_rf("config")
      File.rm_rf!("tmp")
      File.rm_rf!("priv")
    end
  end

  defp tmp_path(path), do: Path.join(["tmp", path])
end
