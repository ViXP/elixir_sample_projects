defmodule Discuss.Discussions.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @derive { Jason.Encoder, only: [:content, :user] }

  schema "comments" do
    field :content, :string
    belongs_to :user, Discuss.Accounts.User
    belongs_to :topic, Discuss.Discussions.Topic

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs \\ %{}) do
    comment
    |> cast(attrs, ~w[content topic_id user_id]a)
    |> validate_required(~w[content topic_id user_id]a)
  end
end
