defmodule Sulat.SessionController do
  use Sulat.Web, :controller

  def new(conn, _) do
    conn |> render(:new)
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
  end
end
