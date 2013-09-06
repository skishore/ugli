GAME_UNSTARTED = 'unstarted'
GAME_STARTED = 'started'

GAME_SHOWING_CARDS = 'showing_cards'
PICKING_STATE = 'picking'
PICKED_STATE = 'picked'

GAME_SHOWING_RESULT = 'showing_result'
VIEWING_STATE = 'viewing'
READY_STATE = 'picked'

SUITS = [0...4]
VALUES = [0...13]

NUMCARDS = 8

class @nCkServer extends UGLIServer
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
    if @state.state == GAME_SHOWING_CARDS
      if message.type != 'pick':
        throw new UGLIClientError 'Unexpected message type' + message.type

      @state.player_state.
      # UPDATE PICKED CARDS AND POTENTIALLY CHANGE GAME STATE
    else if @state.state == GAME_SHOWING_RESULT
      if message.type != 'ready':
        throw new UGLIClientError 'Unexpected message type' + message.type
    else
      throw new UGLIClientError 'Invalid game state' + @state.state

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
    @state.player_state = {}

    ncards = 0
    cards_set = []
    while ncards < 2 * NUMCARDS
      card = Math.floor Math.random()*13
      suit = Math.floor Math.random()*4
      if suit*13+card not in cards_set
        cards_set.push suit*13+card
        ncards += 1

    dealt = 0
    for player of @players
      @state.player_state.player = PICKING_STATE
      @state.cards.player = []
      for k in [0...NUMCARDS]
        @state.cards.player.push cards_list[dealt++]







