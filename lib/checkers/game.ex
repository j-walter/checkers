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

  # returns the proper row index given a directional checker move
  #
  def get_move_index(idx, direction, hops) do
    if hops <= 0 do
        idx
    else
        row = Integer.floor_div(idx, 4)
        destination_offset = cond do
          direction === "down-left" ->
            3 + if rem(row, 2) === 1, do: 0, else: 1
          direction === "down-right" ->
            4 + if rem(row, 2) === 1, do: 0, else: 1
          direction === "up-left" ->
            -4 + if rem(row, 2) === 1, do: -1, else: 0
          direction === "up-right" ->
            -3 + if rem(row, 2) === 1, do: -1, else: 0
          true ->
            -1
        end
        next_val = idx + destination_offset
        next_val = if Kernel.abs(row - Integer.floor_div(next_val, 4)) === 1, do: next_val, else: -1
        get_move_index(next_val, direction, hops - 1)
    end
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

  # returns a list of the valid moves and the pieces eliminated if a particular move is made
  def valid_moves_helper(idx, piece, tiles) do
    player_index = piece[:player]
    possible_directions = cond do
      piece[:king] ->
        ["down-left", "down-right", "up-left", "up-right"]
      player_index === 0 ->
        ["down-left", "down-right"]
      player_index === 1 ->
        ["up-left", "up-right"]
    end

    possible_move_indexes = Enum.reduce(possible_directions, [], fn(x, acc) ->
      [{get_move_index(idx, x, 1), get_move_index(idx, x, 2)} | acc]
    end)
    Enum.reduce(possible_move_indexes, %{}, fn(x, acc) ->
      direct_candidate = elem(x, 0)
      hop_candidate = elem(x, 1)
      hopped_piece = if !!Map.get(tiles, direct_candidate, []) and Map.get(tiles, direct_candidate, nil)[:player] != piece[:player] and !Map.get(tiles, hop_candidate, []), do: direct_candidate, else: nil
      final_candidate = if !!hopped_piece, do: hop_candidate, else: direct_candidate
      cond do
        final_candidate < 0 or 32 <= final_candidate or !!Map.get(tiles, final_candidate, nil) ->
          acc
        true ->
        Map.put(acc, final_candidate, hopped_piece)
      end
    end)
  end

  def valid_moves(name, user_details, pending_piece) do
    game = get(name)
    player_index = find(user_details["email"], game[:players])
    # we only want to consider all potential moves if pending_piece is nil, otherwise we want the last pending move index
    pieces_to_consider = if !!pending_piece, do: [Enum.at(pending_piece, -1)], else: 0..31
    Enum.reduce(pieces_to_consider, %{}, fn(x, acc) ->
      piece = Map.get(game[:tiles], x, nil)
      # player can only touch his or her pieces
      if !!piece and piece[:player] === player_index do
        Map.put(acc, x, valid_moves_helper(x, piece, game[:tiles]))
      else
        Map.put(acc, x, %{})
      end
    end)
  end

  def move_helper(idx, piece, pending_piece, tiles, only_hops) do
    if Enum.empty?(pending_piece) do
        tiles
    else
      next_possible_moves = valid_moves_helper(idx, piece, tiles)
      next_index = List.first(pending_piece)
      if Map.has_key?(next_possible_moves, next_index) and (!only_hops or !!Map.get(next_possible_moves, next_index, nil)) do
        # we need to see this the piece became a king
        new_piece = if piece[:player] === 0 and 28 <= next_index or piece[:player] === 1 and next_index <= 3, do: Map.merge(piece, %{king: true}), else: piece
        new_tiles = Map.put(Map.put(tiles, idx, nil), next_index, new_piece)
        hopped_piece = Map.get(next_possible_moves, next_index, nil)
        move_helper(List.first(pending_piece), new_piece, List.delete_at(pending_piece, 0), (if !hopped_piece, do: new_tiles, else: Map.put(new_tiles, hopped_piece, nil)), true)
      else
        # just return empty map so state isn't updated
        %{}
      end
    end
  end

  # pending_piece is a sequence of move indexes starting with the origin
  def move(name, user_details, pending_piece) do
    game = get(name)
    piece_from = Enum.at(game[:tiles], Enum.at(pending_piece, 0), nil)
    player_index = find(user_details["email"], game[:players])
    # ensure it is the player's turn and validate that the piece being moved is owned by the player
    if !!pending_piece and 1 < length(pending_piece) and rem(game[:turn], 2) === player_index and !!piece_from and player_index === piece_from[:player] do
      # remove the old piece
      GameAgent.put(name,
        Map.merge(game, %{tiles: move_helper(Enum.at(pending_piece, 0), piece_from, List.delete_at(pending_piece, 0), game[:tiles], false), turn: game[:turn] + 1})
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
