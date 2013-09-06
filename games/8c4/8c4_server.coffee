GAME_UNSTARTED = 'unstarted'
GAME_STARTED = 'started'
SUITS = [0...4]
VALUES = [0...13]

class @8c4Server extends UGLIServer

  initialize_state: (config) ->
    # Initialize @state based on config, or throw an UGLIClientError if config
    # is invalid.
    @state.state = GAME_UNSTARTED

  get_player_view: (player) ->
    # Return the view of the game that the given player should see right now.
    #
    # The default implementation makes the entire state visible.
    return @state

  get_num_players: ->
    return (player for player of @players).length

  get_public_view: ->
    return open: @get_num_players() < 2

  handle_message: (player, message) ->
    # Called when a client calls @ugli.send message.
    console.log '8c4Server.handle_message has not been implemented.'

  join_game: (player) ->
    n = @get_num_players()
    if n == 2
      throw new UGLIClientError 'Already have enough players'
    if n == 1
      players = (player for player of @players)
      players.push player
      start_round players

  leave_game: (player) ->
    @state.state = GAME_UNSTARTED
    # TODO: delete other existent state
    delete @state.cards

  start_round: (players) ->
    if players.length != 2
      throw new UGLIClientError 'Tried to start round with not exactly 2 players'
    @state.state = GAME_STARTED
    @state.cards = {}

    ncards = 0
    cards_set = {}
    while ncards < 8

    for player of @players
