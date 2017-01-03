defmodule Sulat.PageController do
  use Sulat.Web, :controller

  alias Sulat.Post

  def index(conn, _params) do
    posts = Repo.all(Post)
    render conn, "index.html", posts: posts
  end
end
