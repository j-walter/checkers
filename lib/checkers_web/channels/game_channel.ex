defmodule CheckersWeb.GameChannel do

  use CheckersWeb, :channel
  alias Checkers.Game

  def join("game:" <> name, _payload, socket) do
    game = Game.get(name)
    cond do
      authenticated?(socket, name) and !game ->
        Game.new(name, socket.assigns[:user_details])
        {:ok, Game.client_view(name), socket |> assign(:name, name)}
      !!game ->

        {:ok, Game.client_view(name), socket |> assign(:name, name)}
      true ->
        {:error, %{reason: "unauthorized"}}
    end
  end

  defp authenticated?(socket, name) do
    !!Map.get(socket.assigns, :user_details, nil)
  end

  def handle_in("valid_moves", %{}, socket) do
    name = socket.assigns[:name]
    {:reply, {:ok, Game.valid_moves(name, socket.assigns[:user_details])}, socket}
  end


end
