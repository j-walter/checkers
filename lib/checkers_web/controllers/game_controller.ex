defmodule CheckersWeb.GameController do
  use CheckersWeb, :controller
  alias Checkers.GameAgent

  def index(conn, _params) do
    games = GameAgent.list
    render(conn, "index.html", "games": games)
  end
end
