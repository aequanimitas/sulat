defmodule Sulat.PostController do
  use Sulat.Web, :controller

  alias Sulat.Post

  @needs_auth ~w(edit create new update delete)a
  # only in :edit and :update, checks if post is user's own
  @ownership ~w(edit update)a

  plug :authenticate_user when action in @needs_auth
  plug :is_owner when action in @ownership

  def index(conn, _params, user) do
    posts = Repo.all(Post)
    render(conn, "index.html", posts: posts)
  end

  # Instead of getting the :active_user inside conn in every function, override action
  # so that it passes the :active_user as the specific user that has a relationship
  # with the post
  def action(conn, _params) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.active_user])
  end

  # this is "/posts/new", just returns a form for creating a new post
  def new(conn, _params, user) do
    changeset = 
      user
      |> build_assoc(:posts)
      |> Post.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  # This path maps to "/posts", this catches the POST request
  # not to be confused with "/posts/new" which is a GET request
  # that returns a form for creating a new post
  def create(conn, %{"post" => post_params}, user) do
    changeset = 
      user
      |> build_assoc(:posts)
      |> Post.changeset(post_params)

    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    post = Repo.get!(Post, id) |> update_text_to_markdown
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}, user) do
    post = Repo.get!(assoc(user, :posts), id)
    changeset = Post.changeset(post) 
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get! Post, id
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    post = Repo.get!(Post, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end

  def is_owner(conn, _params) do
    %{params: %{"id" => post_id}} = conn
    if(conn.assigns.active_user) do
      if conn.assigns.active_user.id == Repo.get(Post, post_id).user_id do
        conn
      else
        # check logs, should output 0 result in query
        conn
        |> put_flash(:error, "You don't have power here")
        |> redirect(to: post_path(conn, :new))
      end
    else
      conn
      |> put_flash(:error, "You don't have power here")
      |> redirect(to: page_path(conn, :index))
    end
  end

  def update_text_to_markdown(post) do
    %{post | text: post.text |> Earmark.to_html}
  end

  def single_result_qry(id) do
    from p in Post, 
    select: struct(p, [:text, :title, :id]), 
    preload: [:user],
    where: p.id == ^id
  end
end
