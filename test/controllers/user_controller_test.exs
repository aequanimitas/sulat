defmodule Sulat.UserControllerTest do
  use Sulat.ConnCase

  setup do
    user = create_user()
    conn = assign(build_conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "/session/new renders a login form", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end
end
