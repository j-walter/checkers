defmodule CheckersWeb.AuthController do
  use CheckersWeb, :controller
  alias Checkers.AuthAgent

  plug Ueberauth

  def new(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    IO.inspect(conn)
    conn = if Map.get(auth.extra.raw_info.user, "email_verified", false) do
      AuthAgent.put(get_session(conn, "user_token"), auth)
      put_session(conn, "user_auth", auth)
    end
    conn
    |> Phoenix.Controller.redirect(to: "/")
  end

end
