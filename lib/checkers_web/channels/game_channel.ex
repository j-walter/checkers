defmodule CheckersWeb.GameChannel do

  use CheckersWeb, :channel
  alias Checkers.Game

  def join("game:" <> name, _payload, socket) do
    game = Game.get(name)
    cond do
      authenticated?(socket, name) and !game ->
        Game.new(name, socket.assigns[:user_details])
        socket
        |> assign(:name, name)
        IO.inspect(Game.client_view(name))
        {:ok, Game.client_view(name), socket}
      !!game ->
        socket
        |> assign(:name, name)
        {:ok, Game.client_view(name), socket}
      true ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  defp authenticated?(socket, name) do
    !!Map.get(socket.assigns, :user_details, nil)
  end


  def handle_in("move", %{"old_index" => old_index, "new_index" => new_index}, socket) do
    name = socket.assigns[:name]
    game = Game.get(name)
    {:reply, {:ok, Game.client_view(game)}, socket}
  end

end
