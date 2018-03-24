defmodule CheckersWeb.GameChannel do

  use CheckersWeb, :channel
  alias Checkers.Game

  def join("game:" <> name, _payload, socket) do
    game = Game.get(name)
    cond do
      authenticated?(socket) and !game ->
        {:ok, Game.client_view(Game.new(name, socket.assigns[:user_details])), socket |> assign(:name, name)}
      !!game ->
        {:ok, Game.client_view(game), socket |> assign(:name, name)}
      true ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  defp authenticated?(socket) do
    !!Map.get(socket.assigns, :user_details, nil)
  end

  def handle_in("valid_moves", %{}, socket) do
    name = socket.assigns[:name]
    {:reply, {:ok, Game.valid_moves(name, socket.assigns[:user_details])}, socket}
  end

  def handle_in("move", %{"from" => from, "to" => to}, socket) do
    name = socket.assigns[:name]
    {:reply, {:ok, Game.client_view(Game.move(name, socket.assigns[:user_details], from, to))}, socket}
  end

end
