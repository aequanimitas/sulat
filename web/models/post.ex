defmodule Sulat.Post do
  use Sulat.Web, :model

  schema "posts" do
    field :text, :string
    field :title, :string

    belongs_to :user, Sulat.User

    timestamps()
  end

  # Use a word list sigil with an "a" modifier that specifies each element's type as atom
  @required_fields ~w(title text)a

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end
end
