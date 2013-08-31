# An instance of UGLIClient stores the following data about the game:
#   @players: map from current player names -> _ids
#   @view: immutable view of game state
#   @me: which player this client is for
#   @container: a jQuery-wrapped div that contains the game UI
#
# An implementation of UGLIServer should override the following methods:
#   @make_config_ui: (container, start_game) ->
#   make_game_ui: ->
#   handle_update: (players, view) ->
# See below for detailed specifications for these methods.

class @UGLIClient
  constructor: (user, room, game_state, @container) ->
    @_user_id = user._id
    @_room_id = room._id
    @me = user.username
    @view = game_state.user_views[user._id]
    @_set_game_state game_state

  _set_game_state: (game_state) ->
    @_index = game_state.index
    @players = game_state.players
    @view = game_state.user_views[@_user_id]

  _handle_update: (game_state) ->
    # Framework's wrapper method around implemenations of handle_update.
    if game_state.index > @_index
      @handle_update game_state.players, game_state.view
      @_set_game_state game_state

  send: (message) ->
    Meteor.call 'send_game_message', @_room_id, message, (err, result) ->
      console.log err if err

  '''
  Client interface methods follow. To write a new game, override these methods.
  '''

  @make_config_ui: (container, start_game) ->
    # Constructs config UI inside the given jQuery-wrapped container.
    #
    # The UI should include a submit button, which, when clicked, calls the
    # start_game callback with the config of the new game.
    #
    # The default implementation creates UI for a game which needs no config.
    container.append(
      $('<span>').text('Set up a new game here: '),
      $('<button>').addClass('create-button').text('Create').on(
        'click', -> start_game {}
      ),
    )

  make_game_ui: ->
    # Constructs game UI inside an empty @container.
    console.log 'UGLIClient.make_game_ui has not been implemented.'

  handle_update: (players, view) ->
    # Takes a new list of players and a new view and updates the game UI.
    console.log 'UGLIClient.handle_update has not been implemented.'
