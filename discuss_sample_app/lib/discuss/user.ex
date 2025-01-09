defmodule Discuss.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive { Jason.Encoder, only: [:email] }

  schema "users" do
    field :token, :string
    field :provider, :string
    field :email, :string
    has_many :topics, Discuss.Topic
    has_many :comments, Discuss.Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:email, :provider, :token])
    |> validate_required([:email, :provider, :token])
  end
end
