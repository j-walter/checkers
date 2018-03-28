defmodule CheckersTest do
  use ExUnit.Case
  doctest Checkers

  test "Basic tests" do
    player1 = Map.put(%{}, "email", "test1@test.com")
    player2 = Map.put(%{}, "email", "test2@test.com")
    Checkers.GameAgent.put("test", Checkers.Game.new("test", player1))
    Checkers.Game.play("test", player2)
    Checkers.Game.move("test", player1, [11, 15])
    Checkers.Game.move("test", player2, [23, 19])
    Checkers.Game.move("test", player1, [10, 14])
    Checkers.Game.move("test", player2, [20, 16])
    Checkers.Game.move("test", player1, [9, 13])
    Checkers.Game.move("test", player2, [21, 17])
    Checkers.Game.move("test", player1, [6, 9])
    Checkers.Game.move("test", player2, [22, 18])
    Checkers.Game.move("test", player1, [1, 6])
    IO.inspect(Checkers.Game.valid_moves("test", player2, [19, 10]))
  end

end

