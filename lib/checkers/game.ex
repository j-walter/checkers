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
        pending_piece: nil,
        players: [user_details["email"]],
        # a game is composed of 32 pieces
        tiles: Enum.reduce(0..31, %{}, fn(x, acc) ->
          cond do
            x <= 11 ->
              Map.put(acc, x,  %{player: 0, king: false, pending_move: false})
            20 <= x ->
              Map.put(acc, x,  %{player: 1, king: false, pending_move: false})
            true ->
              Map.put(acc, x, nil)
          end
        end)
      }
    )
  end

  def valid_moves_helper(idx, piece, board, invert, blacklist) do
    player_index = piece[:player]
    direction = if player_index === invert, do: 1, else: -1
    row = Integer.floor_div(idx, 4) + direction
    offset = if rem(row, 2) === 0, do: -1, else: 1
    move1 = rem(idx, 4) + (row * 4)
    move2 = (if row === Integer.floor_div(move1 + offset, 4), do: move1 + offset, else: nil)
    move1 = (if !!Map.get(board, move1, nil), do: move1 + (3 * offset), else: move1)
    move2 = (if !!move2 and !!Map.get(board, move2, nil), do: (move2 + (3 * offset)) + offset, else: move2 )
    moves = if !!move2, do: [move1 , move2], else: [move1]
    Enum.filter(moves, fn(x) -> !Map.get(board, x, []) and !Enum.member?(blacklist, x) and 0 <= x and x < 32 end) ++ (if piece[:king] and invert === 0, do: valid_moves_helper(idx, piece, board, 1, blacklist), else: [])
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
    player_index = find(user_details["email"], game[:players])
    Enum.reduce(Map.get(game[:pending_piece] || %{}, :idx, nil) || 0..31, %{}, fn(x, acc) ->
      piece = Map.get(game[:tiles], x)
      if !!piece and piece[:player] === player_index do
        Map.put(acc, x, valid_moves_helper(x, piece, game[:tiles], 0, []))
      else
        Map.put(acc, x, [])
      end
    end)
  end

  def move(name, user_details, from, to) do
    game = get(name)
    piece_from = Enum.at(game[:tiles], from, nil)
    player_index = find(user_details["email"], game[:players])
    # ensure it is the player's turn and validate that the piece being moved is owned by the player
    if rem(game[:turn], 2) === player_index and !!piece_from and player_index === piece_from[:player] and Enum.member?(valid_moves_helper(from, piece_from, game[:tiles], 0, []), to) do
      # remove the old piece
      GameAgent.put(name,
        Map.merge(game, %{tiles: Map.put(Map.put(game[:tiles], from, nil), to, piece_from)})
      )
    else
      game
    end

  end

  def client_view(game) do
    Map.merge(game, %{tiles: Map.values(game[:tiles])})
  end

  def list do
    GameAgent.keys()
  end

end
