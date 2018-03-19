defmodule CheckersWeb.AuthController do
  use CheckersWeb, :controller
  alias Checkers.AuthAgent

  plug Ueberauth

  def new(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    conn = if Map.get(auth.extra.raw_info.user, "email_verified", false) do
      token = :base64.encode(:crypto.strong_rand_bytes(64))
      AuthAgent.put(token, auth)
      put_session(conn, "user_auth", auth)
      |> put_session("user_token", token)
    end
    conn
    |> Phoenix.Controller.redirect(to: "/")
  end

end
