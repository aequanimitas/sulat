defmodule Sulat.PageController do
  use Sulat.Web, :controller

  alias Sulat.Post

  def index(conn, _params) do
    posts = Repo.all(Post) |> Enum.map(&update_text_to_markdown/1)
    render conn, "index.html", posts: posts
  end

  def update_text_to_markdown(post) do
    %{post | text: post.text |> Earmark.to_html}
  end
end
