defmodule Sulat.PostControllerTest do
  use Sulat.ConnCase

  setup do
    user = create_user(username: "hta")
    conn = assign(build_conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "Anon cannot edit a post", %{conn: conn, user: user} do
    post = create_post(user, text: "Test", title: "Title")
    conn = get conn, post_path(conn, :edit, post.id)
    assert html_response(conn, 200)
  end
end
