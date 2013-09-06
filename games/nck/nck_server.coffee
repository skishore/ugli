GAME_UNSTARTED = 'unstarted'
GAME_SHOWING_CARDS = 'showing_cards'
GAME_SHOWING_RESULT = 'showing_result'

SUITS = [0...4]
VALUES = [0...13]

NUM_CARDS = 8
NUM_PASS = 4

class @nCkServer extends UGLIServer
  initialize_state: (config) ->
    # Initialize @state based on config, or throw an UGLIClientError if config
    # is invalid.
    @state.state = GAME_UNSTARTED
    @state.round = 0

  get_player_view: (player) ->
    player_view = state: @state.state, round: @state.round

    if @state.state == GAME_SHOWING_CARDS
      player_view.cards = @state.cards
      player_view.picked = {}
      for other, value of @state.pick
        player_view.picked[other] = Boolean value
      player_view.my_pick = @state.pick[player]
    else if @state.state == GAME_SHOWING_RESULT
      player_view = @state
    else if @state.state == GAME_UNSTARTED
      # do nothing
    else
      assert false, 'Invalid game state #{@state.state}'
    return player_view

  get_num_players: ->
    return (player for player of @players).length

  get_public_view: ->
    return open: @get_num_players() < 2

  handle_message: (player, message) ->
    if @state.state == GAME_SHOWING_CARDS
      if message.type != 'pick'
        throw new UGLIClientError 'Unexpected message type #{message.type}'
      assert message.picked.length == NUM_PASS, 'Passed incorrect number of cards'
      # check that all the indices are sorted and between 0 and NUM_CARDS - 1
      for i, index of message.picked
        assert 0 < index < NUM_CARDS, 'Invalid index #{index}'
        if i > 0
          assert message.picked[i] > message.picked[i-1], 'Picked indices not in sorted order'
      @state.pick[player] = message.picked

      for pick in @state.pick
        if pick == false
          return
      # both players have picked
      @state.state = GAME_SHOWING_RESULT
      @state.ready = {}

      # UPDATE PICKED CARDS AND POTENTIALLY CHANGE GAME STATE
    else if @state.state == GAME_SHOWING_RESULT
      if message.type != 'ready'
        throw new UGLIClientError 'Unexpected message type #{message.type}'

    else
      throw new UGLIClientError 'Invalid game state #{@state.state}'

  join_game: (player) ->
    n = @get_num_players()
    if n == 2
      throw new UGLIClientError 'Already have enough players'
    if n == 1
      players = (other for other of @players)
      players.push player
      @start_round players

  leave_game: (player) ->
    @state.state = GAME_UNSTARTED
    # TODO: delete other existent state
    delete @state.cards

  start_round: (players) ->
    if players.length != 2
      throw new UGLIClientError 'Tried to start round with not exactly 2 players'
    @state.state = GAME_SHOWING_CARDS
    @state.round += 1
    @state.cards = {}
    @state.pick = {}

    ncards = 0
    cards_list = []
    cards_set = {}

    while ncards < 2 * NUM_CARDS
      card = Math.floor Math.random()*13
      suit = Math.floor Math.random()*4
      if suit*13+card not of cards_set
        cards_set[suit*13+card] = true
        cards_list.push [suit,card]
        ncards += 1

    dealt = 0
    for player in players
      @state.pick[player] = false
      @state.cards[player] = []
      for k in [0...NUM_CARDS]
        @state.cards[player].push cards_list[dealt]
        dealt += 1

