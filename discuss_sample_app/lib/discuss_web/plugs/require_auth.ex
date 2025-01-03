defmodule DiscussWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias DiscussWeb.Router.Helpers

  def init(params) do
    params
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "Please, sign in to perform this action!")
      |> redirect(to: Helpers.topic_path(conn, :index))
      |> halt()
    end
  end
end
