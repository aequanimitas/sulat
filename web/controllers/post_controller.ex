defmodule Sulat.PostController do
  use Sulat.Web, :controller

  alias Sulat.Post

  @needs_auth ~w(edit create new update delete)a
  # only in :edit and :update, checks if post is user's own
  @ownership ~w(edit update)a

  plug :authenticate_user when action in @needs_auth
  plug :is_owner when action in @ownership

  def index(conn, _params, _user) do
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

  def show(conn, %{"id" => id}, _user) do
    case Repo.get(Post, id) do
      nil -> 
        conn
        |> put_status(404)
        |> render(Sulat.ErrorView, :"404", message: "Post not found")
      post -> 
        post = update_text_to_markdown post
        render(conn, :show, post: post)
    end
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

  defp get_single_post(nil) do {:error, "Post doesn't exist"} end
  defp get_single_post(post) do {:ok, post} end

  defp user_is_owner(u, p) do
    if u.id == p.user_id do
      {:ok, true}
    else
      {:ok, false}
    end
  end

  def is_owner(conn, _params) do
    %{params: %{"id" => post_id}} = conn
    with {:ok, user} <- active_user_exists(conn),
         {:ok, post} <- Repo.get(Post, post_id) |> get_single_post,
         {:ok, post} <- user_is_owner(user, post)
    do
      conn
    else
      err ->
        conn
        |> put_flash(:error, err)
        |> redirect(to: page_path(conn, :index))
    end
  end

  defp active_user_exists(nil) do {:error, "Unauthorized"} end
  defp active_user_exists(conn) do {:ok, conn.assigns.active_user} end

  def update_text_to_markdown(post) do
    %{post | text: post.text |> Earmark.to_html}
  end
end
