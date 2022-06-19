defmodule PhxTest.PhxTestAppTest do
  use PhxTestAppWeb.ConnCase

  test "/", %{conn: conn} do
    assert conn
           |> get("/")
           |> html_response(200) =~ "Welcome to Phoenix!"
  end
end
