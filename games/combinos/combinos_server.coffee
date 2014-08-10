class @CombinosServer extends UGLIServer
  initialize_state: (config) ->
    if config.game_type not in CombinosBase.game_types
      throw new UGLIClientError "Invalid game_type: #{config.game_type}"
    @game_type = config.game_type
    @num_players = 0
    @max_players = CombinosBase.max_players @game_type
    @boards = {}
    @seed = (do new Date().getTime)

  get_lobby_view: ->
    description: CombinosBase.description @game_type
    explanation: CombinosBase.explanation @game_type
    open: @num_players < @max_players
    max_players: @max_players

  get_player_view: (player) -> {}

  get_public_view: ->
    boards = {}
    for player, board of @boards
      boards[player] = do board.serialize
    boards: boards
    game_type: @game_type
    max_players: @max_players
    num_players: @num_players

  handle_message: (player, message) ->
    if message.game_index != @boards[player].gameIndex
      throw new UGLIClientError "Got update for old game: #{message.game_index}"
    if message.type == 'move'
      @handle_move player, message.move_queue
    else if message.type == 'start'
      @handle_start player
    else
      throw new UGLIClientError "Unknown message type: #{message.type}"

  handle_move: (player, move_queue) ->
    check move_queue, [{syncIndex: Number, move: [[Number]]}]
    for move in move_queue
      if @boards[player].syncIndex < move.syncIndex
        for keys in move.move
          @boards[player].update keys

  handle_start: (player) ->
    if @boards[player].state != combinos.Constants.GAMEOVER
      throw new UGLIClientError "Can't reset #{@boards[player].state} board"
    do @boards[player].reset

  join_game: (player) ->
    if @num_players == @max_players
      throw new UGLIClientError "#{player} joined a full game!"
    @num_players += 1
    @boards[player] = new combinos.ServerBoard @seed

  leave_game: (player) ->
    @num_players -= 1
    delete @boards[player]