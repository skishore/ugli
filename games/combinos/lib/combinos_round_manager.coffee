WAITING = 3 # combinos.Constants.WAITING


class @CombinosRoundManager
  constructor: (@game) ->
    assert not @game.singleplayer
    @reset (do new Date().getTime)

  reset: (time) ->
    @start_time = time
    @duration = CombinosBase.round_duration @game.game_type
    # The number and set of players currently in the round.
    # If a player leaves a round, they will still be included in scores
    # and they will still be scored when the round ends, but they will
    # not be in @players.
    @num_players = 0
    @players = {}
    @playing = false
    @scores = {}

  serialize: ->
    start_time: @start_time
    duration: @duration
    playing: @playing
    scores: @scores

  handle_update: ->
    time = (do new Date().getTime)
    if @playing
      num_players_alive = 0
      for player of @players
        # Pick up score updates from boards in the PLAYING or GAMEOVER states.
        if player of @game.boards and @game.boards[player]?.state != WAITING
          @scores[player] = @game.boards[player].score
          if @game.boards[player].state == combinos.Constants.PLAYING
            num_players_alive += 1
      if (time > @start_time + @duration) or @num_players <= 1
        @end_round time
      else if @game.game_type == 'battle' and num_players_alive <= 1
        @end_round time
    else if time > @start_time and @game.num_players > 1
      @start_round time

  join_game: (player) ->
    @game.boards[player].state = WAITING
    do @handle_update

  leave_game: (player) ->
    if player of @players
      delete @players[player]
      @num_players -= 1
      do @handle_update

  start_round: (time) ->
    @start_time = time
    @playing = true
    @game.seed = Math.floor (1 << 30)*(do Math.random)
    for player of @game.boards
      @game.boards[player].reset @game.seed
      @players[player] = true
      @scores[player] = 0
    @num_players = @game.num_players

  end_round: (time) ->
    console.log "Ending round:"
    console.log do @serialize
    @reset time + CombinosBase.between_round_duration
    for player of @game.boards
      @game.boards[player].state = WAITING
      do @game.boards[player].forceClientUpdate
