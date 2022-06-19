defmodule PhxTestAppWeb.PageController do
  use PhxTestAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
