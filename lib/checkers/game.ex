defmodule Checkers.Game do
  alias Checkers.GameAgent

  def get(name) do
    GameAgent.get(name) || nil
  end

  def new(name, user_details) do
    GameAgent.put(name,
      %{
        name: name, turn: 0,
        players: [user_details["email"]],
        # a game is composed of 32 pieces
        tiles: (for _ <- 0..11, do: %{player: 0, king: false}) ++ (for _ <- 0..7, do: nil) ++ (for _ <- 0..11, do: %{player: 1, king: false})
      }
    )
    get(name)
  end

  def client_view(name) do
    game = GameAgent.get(name)
    game
  end

  def move

  def list do
    GameAgent.keys()
  end

end