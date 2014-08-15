RoundStates = CombinosBase.ROUND_STATES
WAITING = 3 # combinos.Constants.WAITING


class @CombinosRoundManager
  constructor: (@game) ->
    assert not @game.singleplayer
    @next_time = (do new Date().getTime)
    @scores = {}
    @state = RoundStates.NOT_STARTED

  serialize: ->
    next_time: @next_time
    scores: @scores
    state: @state

  handle_update: ->
    time = (do new Date().getTime)
    # If the round is waiting for time, continue after time > next_time.
    if @state == RoundStates.WAITING_FOR_TIME
      if time > @next_time
        @state = RoundStates.WAITING_FOR_PLAYERS
    # If the round is waiting for a second player, check if we have it.
    if @state == RoundStates.WAITING_FOR_PLAYERS
      if @game.num_players > 1
        @start_round time
    # Otherwise, if the round is being played, check if it is over. A round
    # can end in either of two ways:
    #   - Time runs out (that is, time > next_time)
    #   - The game is a battle and a single player is left
    else if @state == RoundStates.PLAYING
      num_players_alive = 0
      for player of @scores
        # Pick up score updates from boards in the PLAYING or GAMEOVER states.
        if player of @game.boards and @game.boards[player]?.state != WAITING
          @scores[player] = @game.boards[player].score
          if @game.boards[player].state == combinos.Constants.PLAYING
            num_players_alive += 1
      if time > @next_time
        @end_round time
      else if @game.game_type == 'battle' and num_players_alive <= 1
        @end_round time

  join_game: (player) ->
    @game.boards[player].state = WAITING
    @game.boards[player].pauseReason = {text: 'Waiting for next round...'}
    do @handle_update

  start_round: (time) ->
    @next_time = time + CombinosBase.ROUND_DURATIONS[@game.game_type]
    @scores = {}
    @state = RoundStates.PLAYING
    # Update the server seed and reset each client's board.
    # Additionally, record each client's score in the score dictionary so that
    # we know who was in the round to start.
    @game.seed = Math.floor (1 << 30)*(do Math.random)
    for player of @game.boards
      @game.boards[player].reset @game.seed
      @scores[player] = 0

  end_round: (time) ->
    ranking = do @get_round_ranking
    console.log 'Ranking:', ranking
    for player, board of @game.boards
      text = ranking[player] or 'Waiting for next round...'
      board.pauseReason = {last_state: board.state, text: text}
      board.state = WAITING
      do board.forceClientUpdate
    # We modify next_time and state so that clients will update their timers,
    # but keep scores so that they can review the results of the last game.
    @next_time = time + CombinosBase.BETWEEN_ROUND_DURATION
    @state = RoundStates.WAITING_FOR_TIME

  get_round_ranking: ->
    ranking = {}
    if @game.game_type == 'battle'
      for player of @scores
        if @game.boards[player]?.state == combinos.Constants.PLAYING
          ranking[player] = 1
        else
          ranking[player] = 2
    else if @game.game_type == 'race'
      scores = ([player, score] for player, score of @scores)
      scores.sort (a, b) -> b[1] - a[1]
      for row, i in scores
        ranking[row[0]] = i + 1
    ranking
