defmodule Sulat.Auth do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias Sulat.Router.Helpers  # *_path

  @doc """
  Extract the app repo that was passed when the plug was "plugged"
  """
  def init(opts) do
    Keyword.fetch! opts, :repo
  end

  @doc """
  :user_id comes from 2 sources: after logging in or after registration
  """
  def call(conn, repo) do
    user_id = get_session(conn, :active_user_id)
    cond do
      user = conn.assigns[:active_user] -> 
        conn
      user = user_id && repo.get(Sulat.User, user_id) -> 
        assign(conn, :active_user, user)
      true -> 
        # always runs when logged out, causing errors to the function plug
        assign(conn, :active_user, nil)
    end
  end

  def login(conn, user) do
    conn
    # put user in conn struct
    |> assign(:active_user, user)
    # add user.id to session, use :user_id as session label
    |> put_session(:active_user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    # drop all existing sessions
    configure_session(conn, drop: true)
  end

  def login_with_username_password(conn, username, password, opts) do
    repo = Keyword.fetch! opts, :repo
    user = repo.get_by Sulat.User, username: username
    cond do
      # user exists, password from form and saved password from user matches
      user && checkpw(password, user.password_hash) ->
        {:ok, login(conn, user)}
      # user found but wrong credentials, still return conn
      user ->
        {:error, :unauthorized, conn}
      # user not found ,still return conn
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.active_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
