defmodule CheckersTest do
  use ExUnit.Case
  doctest Checkers

  test "Basic tests" do
    player1 = Map.put(%{}, "email", "test1@test.com")
    player2 = Map.put(%{}, "email", "test2@test.com")
    game = Checkers.GameAgent.put("test", Checkers.Game.new("test", player1))
    game = Checkers.GameAgent.put("test", Map.merge(game, %{tiles: Map.merge(game[:tiles], Map.put(Map.put(game[:tiles], 9, nil), 3, nil))}))
    #Checkers.Game.play("test", player2)
    IO.inspect(Checkers.Game.get("test"))
    game = Checkers.Game.play("test", player2)
    IO.inspect(game)
    IO.inspect(Checkers.Game.valid_moves("test", player1, nil))
  end

end

