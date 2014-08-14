class @CombinosServer extends UGLIServer
  initialize_state: (config) ->
    if config.game_type not in CombinosBase.GAME_TYPES
      throw new UGLIClientError "Invalid game_type: #{config.game_type}"
    @boards = {}
    @game_type = config.game_type
    @max_players = CombinosBase.MAX_PLAYERS[@game_type]
    @num_players = 0
    @singleplayer = @game_type == 'singleplayer'
    if not @singleplayer
      @round_manager = new CombinosRoundManager @
    # The only piece of state that is private to the server.
    @seed = Math.floor (1 << 30)*(do Math.random)

  get_lobby_view: ->
    description: CombinosBase.DESCRIPTIONS[@game_type]
    explanation: CombinosBase.EXPLANATIONS[@game_type]
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
    round: do @round_manager?.serialize
    singleplayer: @singleplayer

  handle_message: (player, message) ->
    if message.game_index != @boards[player].gameIndex
      throw new UGLIClientError "Got update for old game: #{message.game_index}"
    if message.type == 'move'
      @handle_move player, message.move_queue
    else if message.type == 'start'
      @handle_start player
    else
      throw new UGLIClientError "Unknown message type: #{message.type}"
    do @round_manager?.handle_update

  handle_move: (player, move_queue) ->
    check move_queue, [{syncIndex: Number, move: [[Number]]}]
    if @boards[player].state != combinos.Constants.PLAYING
      throw new UGLIClientError "#{player}'s board is not PLAYING"
    for move in move_queue
      if @boards[player].syncIndex < move.syncIndex
        for keys in move.move
          @boards[player].update keys

  handle_start: (player) ->
    if not @singleplayer
      throw new UGLIClientError "Can't press start in #{@game_type} game"
    if @boards[player].state != combinos.Constants.GAMEOVER
      throw new UGLIClientError "Can't reset #{@boards[player].state} board"
    do @boards[player].reset

  join_game: (player) ->
    if @num_players == @max_players
      throw new UGLIClientError "#{player} joined a full game!"
    @num_players += 1
    @boards[player] = new combinos.ServerBoard @seed
    @round_manager?.join_game player

  leave_game: (player) ->
    @num_players -= 1
    delete @boards[player]
    @round_manager?.leave_game player
