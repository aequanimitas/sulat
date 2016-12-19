defmodule Sulat.PageController do
  use Sulat.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
