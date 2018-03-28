defmodule CheckersWeb.InjectToken do
  @behaviour Plug
  import Plug.Conn

  def init(default) do
    default
  end

  def call(conn, _default) do
    if !get_session(conn, "user_token"), do: put_session(conn, "user_token", :base64.encode(:crypto.strong_rand_bytes(64))), else: conn
  end

end
