defmodule CheckersWeb.Authentication do
  @behaviour Plug
  import Plug.Conn

  def init(default) do
    default
  end

  def call(conn, _default) do
    if !!get_session(conn, "user_auth") do
      conn
    else
      Phoenix.Controller.redirect(conn, to: "/auth/google")
    end
  end

end
