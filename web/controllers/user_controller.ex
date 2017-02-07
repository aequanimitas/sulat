defmodule Sulat.UserController do
  use Sulat.Web, :controller

  alias Sulat.User

  @auth ~w(edit)a
  @view_permissions ~w(show update)a ++ @auth
  plug :authenticate_user when action in @auth
  plug :is_owner when action in @view_permissions

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, :index, users: users)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.pw_hash_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        # change path to somewhere more useful
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:info, "Errors.")
        |> render(:new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    if (conn.assigns.owner) do
      render(conn, :edit, user: user, changeset: changeset)
    else
      redirect(conn, to: user_path(conn, :new))
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, :edit, user: user, changeset: changeset)
    end
  end

  # this can be generalized, but favor specialization for now
  def is_owner(conn, _params) do
    %{params: %{"id" => user_id}} = conn
    # needs this check here for logged out users
    if (conn.assigns.active_user) do
      if(Repo.get(User, user_id).id == conn.assigns.active_user.id) do
        assign(conn, :owner, true)
      end
    else
      assign(conn, :owner, false)
    end
  end

  #def delete(conn, %{"id" => id}) do
  #  user = Repo.get!(User, id)

  #  # Here we use delete! (with a bang) because we expect
  #  # it to always work (and if it does not, it will raise).
  #  Repo.delete!(user)

  #  conn
  #  |> put_flash(:info, "User deleted successfully.")
  #  |> redirect(to: user_path(conn, :index))
  #end
end
