defmodule Sulat.AuthTest do
  use Sulat.ConnCase
  alias Sulat.Auth

  setup %{conn: conn} do
    conn = conn
           |> bypass_through(Sulat.Router, :browser)
           |> get("/")
    {:ok, %{conn: conn}}
  end
  
  test "authentication halts when :user does not exist", %{conn: conn} do
    # authenticate_user expects key :user to exist
    # since auth is still not wired with the routes, assign :user to nil here
    conn = conn |> assign(:user, nil) |> Sulat.Auth.authenticate_user([])
    assert conn.halted
  end

  test "authentication proceeds when :user exists", %{conn: conn} do
    conn = conn |> assign(:user, %Sulat.User{}) |> Sulat.Auth.authenticate_user([])
    refute conn.halted()
  end

  test "logging in", %{conn: conn} do
    login_conn = conn
                 |> Sulat.Auth.login(%Sulat.User{id: 100})
                 |> send_resp(:ok, "")
    next_conn = get(login_conn, "/")
    assert get_session(next_conn, :user_id) == 100
  end

  test "logging out", %{conn: conn} do
    login_conn = conn
                 |> put_session(:user_id, 100)
                 |> Sulat.Auth.logout()
                 |> send_resp(:ok, "")
    next_conn = get(login_conn, "/")
    refute get_session(next_conn, :user_id)
  end

  test "put Sulat.User from session into assigns", %{conn: conn} do
    user = create_user()
    conn = conn |> put_session(:user_id, user.id) |> Sulat.Auth.call(Sulat.Repo)
    assert user.id == conn.assigns.user.id
  end

  test "call with no session yields to a nil :user", %{conn: conn} do
    conn = Sulat.Auth.call(conn, Sulat.Repo)
    assert nil == conn.assigns.user
  end

  test "testing whole pipeline", %{conn: conn} do
    user = create_user()
    conn =
      conn
      |> Auth.login(user)
      |> Auth.authenticate_user("")
      |> Auth.call(Sulat.Repo)
    assert user.id == conn.assigns.user.id

    conn = Auth.logout(conn) |> send_resp(:ok, "") |> get("/")
    refute get_session(conn, :user_id)
  end

  test "dropping session?", %{conn: conn} do
    # redirect to invoke next action, no transformations happen
    # if you don't proceed to the next action(?)
    login_conn = conn |> Auth.logout |> get("/")
    assert get_session(login_conn, :user_id) == nil
  end
  
  test "login_with_username_password", %{conn: conn} do
    user = create_user(username: "hec", password: "12345678")
    {:ok, login_conn} = 
      conn
      |> Auth.login_with_username_password("hec", "12345678", repo: Sulat.Repo)
    assert login_conn.assigns.user.id == user.id
  end
  
  test "login with no credentials", %{conn: conn} do
    # initial mistake was using an equality operator ```===```
    # which of course spits an error that ```_``` is an unbound variable
    assert {:error, :not_found, _conn} =
      Auth.login_with_username_password(conn, "hec", "12345", repo: Sulat.Repo)
  end
  
  test "login with wrong credentials", %{conn: conn} do
    _ = create_user(username: "hec", password: "12345678")
    assert {:error, :unauthorized, _conn} =
      Auth.login_with_username_password(conn, "hec", "12345", repo: Sulat.Repo)
  end
end
