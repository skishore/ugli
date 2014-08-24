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

  handle_client_update: ->
    # Do basic checks to make sure the client isn't crazy, then a full update.
    if @state == RoundStates.WAITING_FOR_TIME or @state == RoundStates.PLAYING
      if (do new Date().getTime) > @next_time
        do @handle_update

  handle_late_start: (player) ->
    if @can_start_late player
      @game.boards[player].reset @game.seed
      @scores[player] = 0

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
    # can end in several ways:
    #   - Time runs out (that is, time > next_time)
    #   - Everyone is either knocked out or leaves
    #   - There is only one player left and he is guaranteed to win
    else if @state == RoundStates.PLAYING
      num_players_alive = 0
      live_player_score = 0
      for player of @scores
        board = @game.boards[player]
        # Pick up score updates from boards in the PLAYING or GAMEOVER states.
        if board? and board.state != WAITING
          @scores[player] = board.score
          if board.state == combinos.Constants.PLAYING
            num_players_alive += 1
            live_player_score = board.score
      if (time > @next_time) or (num_players_alive == 0) or
         (num_players_alive == 1 and @last_player_wins live_player_score)
        @end_round time

  last_player_wins: (score) ->
    # Return true if this score is the unique maximum score in @scores.
    number_of_good_scores = 0
    for _, other_score of @scores
      if other_score >= score
        number_of_good_scores += 1
    return number_of_good_scores == 1

  join_game: (player) ->
    @game.boards[player].state = WAITING
    @game.boards[player].pauseReason = {text: 'Waiting for next round...'}
    if @can_start_late player
      @game.boards[player].pauseReason.start_game_text = 'Click to start late'
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

  can_start_late: (player) ->
    @state == RoundStates.PLAYING and player not of @scores and
    CombinosBase.CAN_START_LATE[@game.game_type]

  end_round: (time) ->
    ranking = do @get_round_ranking
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
    # Ranking is dependent only on scores for all game modes.
    ranking = {}
    scores = ([player, score] for player, score of @scores)
    scores.sort (a, b) -> b[1] - a[1]
    for row, i in scores
      ranking[row[0]] = i + 1
    ranking
