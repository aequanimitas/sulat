defmodule Sulat.PostControllerTest do
  use Sulat.ConnCase

  @valid_attrs %{text: "Test Redirect", title: "Title Redirect"}

  setup do
    user = create_user(username: "hta")
    conn = assign(build_conn(), :current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "list all posts", %{conn: conn} do
    conn = get conn, post_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing posts"
  end

  test "create a new post", %{conn: conn} do
    conn = get conn, post_path(conn, :new)
    assert html_response(conn, 200) =~ "New post"
  end

  test "redirect after creating new post", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @valid_attrs
    assert redirected_to(conn) == post_path(conn, :index)
  end

  test "editing a post", %{conn: conn, user: user} do
    post = create_post(user, text: "Test", title: "Title")
    conn = get conn, post_path(conn, :edit, post.id)
    assert html_response(conn, 200)
  end
end
