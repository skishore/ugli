# An instance of UGLIClient stores the following data about the game:
#   @me: which player this client is for
#   @options: the player's current options
#   @view: immutable view of game state
#   @container: a jQuery-wrapped div that contains the game UI
#
# An implementation of UGLIServer should override the following methods:
#   @make_config_ui: (container) ->
#   make_game_ui: ->
#   handle_update: (players, view) ->
# See below for detailed specifications for these methods.

class @UGLIClient
  constructor: (user, room, @container) ->
    @_user_id = user._id
    @_room_id = room._id
    @me = user.username
    @options = user.profile?.options or {}
    @view = @_extract_view room.game
    do @make_game_ui

  _extract_view: (game) ->
    @view = $.extend game.public_view, game.private_views[@_user_id]

  _handle_update: (room) ->
    new_view = @_extract_view room.game
    @handle_update new_view
    @view = new_view

  _handle_options_update: (options) ->
    options = options or {}
    if not _.isEqual @options, options
      @handle_options_update options
      @options = options

  send: (message) ->
    Meteor.call 'send_game_message', @_room_id, message, (err, result) ->
      console.log err if err

  '''
  Client interface methods follow. To write a new game, override these methods.
  '''

  @make_config_ui: (container) ->
    # Constructs config UI inside the given jQuery-wrapped container.
    #
    # This method should return a function that, when called, returns a dict
    # of the current config set in the UI.
    #
    # The default implementation creates UI for a game which needs one piece
    # of config: the number of players.
    container.append(
      $('<span>').text('Number of players: ')
      $('<input type="number" class="max-players" min="2" max="5" value="2">')
    )
    -> max_players: (parseInt (do container.find('.max-players').val), 10)

  @make_help_ui: (container) ->
    # Constructs static help UI inside the given jQuery-wrapped container.
    container.append $('<div>').text 'No help provided.'

  make_game_ui: ->
    # Constructs game UI inside an empty @container.
    console.log 'UGLIClient.make_game_ui has not been implemented.'

  handle_update: (view) ->
    # Takes a new view and updates the UI. The last view is available in @view.
    console.log 'UGLIClient.handle_update has not been implemented.'

  handle_options_update: (options) ->
    # Takes a new options dict and updates the UI. Old options are in @options.
    console.log 'UGLIClient.handle_options_update has not been implemented.'
