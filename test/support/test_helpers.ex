defmodule Sulat.TestHelpers do
  alias Sulat.Repo

  # create user for tests
  def create_user(attrs \\ %{}) do
    changeset = Dict.merge(%{
      username: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}",
      email: "lala@gmail.com",
      password: "secretly"
    }, attrs)

    %Sulat.User{}
    |> Sulat.User.pw_hash_changeset(changeset)
    |> Repo.insert!()
  end

  # passes a user, then create a post
  def create_post(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:posts, attrs)
    |> Repo.insert!()
  end
end
