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
    would_forfeit: @round_manager?.state == CombinosBase.ROUND_STATES.PLAYING

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
    # Check for the advance-round message.
    if message.type == 'update_round'
      do @round_manager?.handle_client_update
      return
    else if message.type == 'start_late'
      @round_manager?.handle_late_start player
      return
    # All other types of updates are game updates.
    if message.game_index != @boards[player]?.gameIndex
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
    board = @boards[player]
    if board.state != combinos.Constants.PLAYING
      throw new UGLIClientError "#{player}'s board is not PLAYING"
    # Get the opponent's board in battle mode to deliver attacks.
    if @game_type == 'battle'
      opponents = (other for other of @boards when other != player)
      opponent = @boards[opponents[0]] if opponents.length > 0
    for move in move_queue
      if board.syncIndex < move.syncIndex
        for keys in move.move
          @make_move board, keys, opponent

  make_move: (board, keys, opponent) ->
    last_score = board.score
    board.update keys
    if board.score != last_score and @game_type == 'battle'
      if opponent?.state == combinos.Constants.PLAYING
        opponent.handleAttack board

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
    settings = {game_type: @game_type, singleplayer: @singleplayer}
    @boards[player] = new combinos.ServerBoard settings, @seed
    @round_manager?.join_game player

  leave_game: (player) ->
    @num_players -= 1
    delete @boards[player]
    do @round_manager?.handle_update

  start_game: ->
    # We don't want round timers to start until the game is started.
    if @round_manager?.state == CombinosBase.ROUND_STATES.NOT_STARTED
      @round_manager.state = CombinosBase.ROUND_STATES.WAITING_FOR_TIME
      do @round_manager.handle_update
