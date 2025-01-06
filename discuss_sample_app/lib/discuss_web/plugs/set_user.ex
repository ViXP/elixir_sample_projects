defmodule DiscussWeb.Plugs.SetUser do
  import Plug.Conn

  alias Discuss.Repo
  alias Discuss.User

  def init(params) do
    params
  end

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Repo.get(User, user_id) ->
        conn
        |> assign(:user, user)
        |> assign(:user_token, Phoenix.Token.sign(conn, "user socket", user.id))
      true ->
        conn
        |> assign(:user, nil)
        |> assign(:user_token, nil)
    end
  end
end
