defmodule Sulat.User do
  use Sulat.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    # intermediary field before hashing
    # doesn't persist in DB, wasn't created during migration
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
  end

  @doc """
    Hash password before saving to DB
  """
  def pw_hash_changeset(model, params) do
    model
    |> changeset(params)
    # pass changeset as first argument starting here
    |> cast(params, ~w(password), [])
    |> validate_length(:password, min: 8, max: 80)
    # before sending back to controller, update changeset with the hashed password
    |> hash_pw
  end

  def hash_pw(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        # Ecto.Changeset.put_change
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ -> changeset
    end
  end
end
