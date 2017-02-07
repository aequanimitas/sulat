defmodule Sulat.UserControllerTest do
  use Sulat.ConnCase

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = create_user(username: username, password: "12345678")
      conn = assign(conn, :active_user, user)
      {:ok, conn: conn, user: user}
    else
      user = create_user()
      conn = assign(build_conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    end
  end

  test "/users/new renders a login form", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end

  test "/users/:id shows user info", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :show, user.id)
    assert html_response(conn, 200) =~ "Show user"
  end

  @tag login_as: "hta"
  test "/users/:id/edit should not redirect", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :edit, user.id)
    assert html_response(conn, 200)
  end

  test "/users/:id/edit should redirect", %{conn: conn, user: user} do
    conn = get conn, user_path(conn, :edit, user.id)
    assert html_response(conn, 302)
  end
end
