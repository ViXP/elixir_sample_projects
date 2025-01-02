defmodule Discuss.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:title]) # produces a changeset, with empty :errors
    |> validate_required([:title]) # add errors to the changeset if occurred
  end
end
