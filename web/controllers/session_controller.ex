defmodule Sulat.SessionController do
  use Sulat.Web, :controller

  def new(conn, _) do
    conn |> render(:new)
  end

  def delete(conn, _) do
    conn
    |> put_flash(:info, "You have been logged out")
    |> Sulat.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    case Sulat.Auth.login_with_username_password(conn, username, password, repo: Repo) do
      {:ok, conn} ->
        %Plug.Conn{assigns: %{user: user}} = conn
        conn
        |> put_flash(:info, "Hi #{user.username} welcome back")
        |> redirect(to: page_path(conn, :index))
      {:error, _, conn} ->
        conn
        |> put_flash(:error, "Invalid credentials")
        |> render(:new)
    end
  end
end
