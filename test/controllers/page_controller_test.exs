defmodule Sulat.PageControllerTest do
  use Sulat.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"

    # look for "Login"
    assert html_response(conn, 200) =~ "Login"
  end
end
