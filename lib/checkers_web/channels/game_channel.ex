defmodule CheckersWeb.GameChannel do

  use CheckersWeb, :channel
  alias Checkers.Game

  def join("game:" <> name, _payload, socket) do
    game = Game.get(name)
    cond do
      authenticated?(socket) and !game and !!name ->
        {:ok, Game.client_view(Game.new(name, socket.assigns[:user_details])), socket |> assign(:name, name)}
      !!game ->
        {:ok, Game.client_view(game), socket |> assign(:name, name)}
      true ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  def broadcast_update(game) do
     CheckersWeb.Endpoint.broadcast("game:" <> game[:name], "update", Game.client_view(game))
  end

  defp authenticated?(socket) do
    !!Map.get(socket.assigns, :user_details, nil)
  end

  def handle_in("valid_moves", %{"pending_piece" => pending_piece}, socket) do
    name = socket.assigns[:name]
    {:reply, {:ok, Game.valid_moves(name, socket.assigns[:user_details], pending_piece)}, socket}
  end

  def handle_in("move", %{"pending_piece" => pending_piece}, socket) do
    name = socket.assigns[:name]
    game = Game.move(name, socket.assigns[:user_details], pending_piece || [])
    broadcast_update(game)
    {:reply, {:ok, Game.client_view(game)}, socket}
  end

  def handle_in("play", %{}, socket) do
    name = socket.assigns[:name]
    game = Game.play(name, socket.assigns[:user_details])
    broadcast_update(game)
    {:reply, {:ok, Game.client_view(game)}, socket}
  end

  intercept ["update"]

  def handle_out("update", payload, socket) do
    push socket, "update", payload
    {:noreply, socket}
  end

end
