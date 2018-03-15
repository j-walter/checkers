defmodule CheckersWeb.RedirectController do
  use CheckersWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/")
  end

end