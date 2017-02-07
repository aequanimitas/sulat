defmodule Sulat.PostViewTest do
  use Sulat.ConnCase, async: true
  import Phoenix.View

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = create_user(username: username, password: "12345678")
      conn = assign(conn, :active_user, user)
      {:ok, conn: conn, user: user}
    else
      user = create_user(username: "hta")
      conn = assign(build_conn(), :active_user, nil)
      {:ok, conn: conn, user: user}
    end
  end

  test "renders index, /posts", %{conn: conn, user: user} do
    posts = [
      %Sulat.Post{id: "1", title: "First Post", text: "First post content"},
      %Sulat.Post{id: "2", title: "Second Post", text: "Second post content"},
      %Sulat.Post{id: "3", title: "Third Post", text: "Third post content"}
    ]
    content = render_to_string(Sulat.PostView, "index.html", conn: conn, posts: posts, active_user: user)
    assert String.contains?(content, "Listing posts")
    for p <- posts do
      assert String.contains?(content, p.title)
    end
  end
end
