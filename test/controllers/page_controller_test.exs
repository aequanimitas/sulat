defmodule Sulat.PageControllerTest do
  use Sulat.ConnCase

  setup do
    user = create_user(username: "hta")
    conn = assign(build_conn(), :user, user)
    {:ok, conn: conn, user: user}
  end

  # without using a plug, conn losts the :user key
  test "check conn retains key :user after request", %{conn: conn} do
    assert conn.assigns[:user]
    conn = get conn, "/"
    assert conn.assigns[:user]
  end

  test "list all posts on index page", %{conn: conn, user: user} do
    first_post = create_post(user, text: "First post text", title: "First post")
    second_post = create_post(user, text: "Second post text", title: "Second post")

    # conn losts the "user" key here, so we need  
    conn = get conn, "/"

    assert conn.assigns[:user]
    assert String.contains?(conn.resp_body, first_post.title)
    assert String.contains?(conn.resp_body, second_post.title)
    assert String.contains?(conn.resp_body, first_post.text)
    assert String.contains?(conn.resp_body, second_post.text)
    refute String.contains?(conn.resp_body, "EDIT")
  end
end
