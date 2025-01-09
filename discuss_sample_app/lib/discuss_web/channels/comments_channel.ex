defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel

  alias Discuss.{Topic, Comment}

  @impl true
  def join("comments:" <> topic_id, payload, socket) do
    if authorized?(payload) do
      topic = Topic
        |> Repo.get!(String.to_integer(topic_id))
        |> Repo.preload(:comments)

      {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("comments:add", %{"content" => content}, socket) do
    changeset =
      socket.assigns.topic
      |> Ecto.build_assoc(:comments)
      |> Comment.changeset(%{content: content, user_id: socket.assigns.user.id})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end