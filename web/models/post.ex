defmodule Sulat.Post do
  use Sulat.Web, :model

  schema "posts" do
    field :text, :string
    field :title, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text, :title])
    |> validate_required([:text, :title])
  end
end
