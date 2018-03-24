defmodule Checkers.Game do
  alias Checkers.GameAgent

  def get(name) do
    GameAgent.get(name) || nil
  end

  def new(name, user_details) do
    GameAgent.put(name,
      %{
        name: name,
        turn: 0,
        players: [user_details["email"]],
        # a game is composed of 32 pieces
        tiles: (for _ <- 0..11, do: %{player: 0, king: false, pending_move: false}) ++ (for _ <- 0..7, do: nil) ++ (for _ <- 0..11, do: %{player: 1, king: false, pending_move: false})
      }
    )
    get(name)
  end

  def valid_moves_helper(idx, piece, board, invert) do
    player_index = piece[:player]
    direction = if player_index === invert, do: 1, else: -1
    row = Integer.floor_div(idx, 4) + direction
    offset = if rem(row, 2) === 0, do: -1, else: 1
    move1 = rem(idx, 4) + (row * 4)
    move2 = (if row === Integer.floor_div(move1 + offset, 4), do: move1 + offset, else: nil)
    move1 = (if !!Enum.at(board, move1, nil), do: move1 + (3 * offset), else: move1)
    move2 = (if !!move2 and !!Enum.at(board, move2, nil), do: (move2 + (3 * offset)) + offset, else: move2 )
    moves = if !!move2, do: [move1 , move2], else: [move1]
    Enum.filter(moves, fn(x) -> !Enum.at(board, x, []) and 0 <= x and x < 32 end) ++ (if piece[:king] and invert === 0, do: valid_moves_helper(idx, piece, board, 1), else: [])
  end

  def find_helper(find, list, idx) do
    cond do
      Enum.empty?(list) ->
        -1
      List.first(list) === find ->
        idx
      true ->
        find_helper(find, Enum.drop(list, 1), idx + 1)
    end
  end

  def find(find, list) do
    find_helper(find, list, 0)
  end

  def valid_moves(name, user_details) do
    game = get(name)
    IO.inspect(game)
    player_index = find(user_details["email"], game[:players])
    Enum.reduce(0..31, %{}, fn(x, acc) ->
      piece = Enum.at(game[:tiles], x)
      if !!piece and piece[:player] === player_index do
        Map.put(acc, x, valid_moves_helper(x, piece, game[:tiles], 0))
      else
        Map.put(acc, x, [])
      end
    end)
  end

  def client_view(name) do
    game = get(name)
    game
  end

  def list do
    GameAgent.keys()
  end

end
