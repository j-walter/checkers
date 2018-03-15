defmodule CheckersWeb.GameChannel do

  use CheckersWeb, :channel
  alias Checkers.Game
  alias Checkers.GameAgent

  def join("game:" <> name, socket) do
    if authorized?(socket, name) do
      game = GameAgent.get(name) || Game.new()
      GameAgent.put(name, game)
      socket = socket
      |> assign(:name, name)
      {:ok, Game.client_view(game), socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  defp authorized?(socket, name) do
    true
  end

end
