defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.Topic

  plug(DiscussWeb.Plugs.RequireAuth when action in ~w(new create edit update delete)a)
  plug(:find_users_topic when action in ~w(edit update delete)a)
  plug(:authorize_users_topic when action in ~w(edit update delete)a)

  def index(conn, _params) do
    render(conn, :index, topics: Repo.all(Topic))
  end

  def show(conn, %{"id" => topic_id}) do
    render(conn, "show.html", topic: Repo.get!(Topic, topic_id))
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})
    render(conn, :new, changeset: changeset)
  end

  def edit(conn, _params) do
    changeset = Topic.changeset(conn.assigns[:topic])
    render(conn, :edit, changeset: changeset, topic: conn.assigns[:topic])
  end

  def create(conn, %{"topic" => new_data}) do
    result =
      conn.assigns[:user]
      |> Ecto.build_assoc(:topics)
      |> Topic.changeset(new_data)
      |> Repo.insert()

    case result do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic created")
        |> redirect(to: topic_path(conn, :index))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"topic" => new_data}) do
    case Topic.changeset(conn.assigns[:topic], new_data) |> Repo.update() do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated")
        |> redirect(to: topic_path(conn, :index))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, topic: conn.assigns[:topic])
    end
  end

  def delete(conn, _params) do
    conn.assigns[:topic] |> Repo.delete!()

    conn
    |> put_flash(:info, "Topic deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  defp find_users_topic(%{params: %{"id" => topic_id}} = conn, _params) do
    topic = Repo.get_by(Topic, id: topic_id, user_id: conn.assigns[:user].id)
    assign(conn, :topic, topic)
  end

  defp authorize_users_topic(conn, _params) do
    if conn.assigns[:topic] do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized for this action!")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end
end
