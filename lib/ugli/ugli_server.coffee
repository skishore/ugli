# UGLIServer is an abstract base class that you should subclass to provide an
# implementation of the server-side logic of your game. There are two classes
# of virtual methods to override:
#   - event handlers: @handle_message, @join_game, @leave_game
#       Override these methods and modify in-memory state based on the update.
#       To avoid getting the server into an inconsistent state, fully validate
#       the update before modifying any state.
#   - view computation: @get_player_view, @get_public_view, @get_lobby_view
#       These methods are used to notify the client of a change to game state.
#       Both the public_view and the player's view are passed to each player.
#       The lobby view is used to populate the game list in the lobby.
#
# UGLIServer instances are also initialized by calling @initialize_state, which
# is passed the rules dict requested by the client.

# See below for detailed specifications for these methods.
#
# The framework also provides a @log_game_message method that can be used to
# push small text status updates to the game log, and methods to record games:
#   @record_singleplayer_game: (player, score) ->
#     Takes a player name and the score they scored and records it.
#   @record_multiplayer_game: (game_type, ranking) ->
#     Takes a string game_type and a dict mapping player names to their
#     1-indexed ranks at the end of the game and records it.

class @UGLIServer
  constructor: (room, config) ->
    model = room.model
    @log_game_message = model.log_game_message.bind model, room
    @record_singleplayer_game = model.record_singleplayer_game.bind model
    @record_multiplayer_game = model.record_multiplayer_game.bind model
    @initialize_state config

  _get_views: (users) ->
    private_views = {}
    for user in users
      private_views[user._id] = @get_player_view user.name
    {private_views: private_views, public_view: do @get_public_view}

  setTimeout: (callback, delay) ->
    throw new NotImplementedError 'UGLIServer.setTimeout'

  clearTimeout: (timeout) ->
    throw new NotImplementedError 'UGLIServer.clearTimeout'

  '''
  Server interface methods follow. To write a new game, override these methods.
  '''

  initialize_state: (config) ->
    # Initialize server from the config. Throw an UGLIClientError if is invalid.
    console.log 'UGLIServer.initialize_state has not been implemented.'

  get_lobby_view: ->
    # Return data about the game that is visible from the lobby. This data is
    # used to populate the game list, so it includes a restricted set of keys:
    #   description: a short description of the game mode (eg, 'Sprint')
    #   explanation: a longer explanation of the game mode
    #   open: boolean that should be true if players can join the game
    #   max_players: the maximum number of players allowed in the game
    #   would_forfeit: (optional) a dict mapping players -> true if, by leaving,
    #                  they would forfeit the current game
    console.log 'UGLIServer.get_lobby_view has not been implemented.'

  get_player_view: (player) ->
    # Return game state that is only visible to the given player.
    #
    # The final view for a player is the public view extended by the private
    # view - that is, the value of shared keys are taken from the private view.
    # (The full private view is available to client-side Javascript, though.)
    console.log 'UGLIServer.get_player_view has not been implemented.'

  get_public_view: ->
    # Return game state that is visible to all players.
    console.log 'UGLIServer.get_public_view has not been implemented.'

  handle_message: (player, message) ->
    # Called when a client calls this.send(message).
    console.log 'UGLIServer.handle_message has not been implemented.'

  join_game: (player) ->
    # Called when a new player wants to join this game. This method should
    # throw an UGLIClientError if the player is not allowed to join.
    #
    # By default, all requests to join are accepted.
    console.log 'UGLIServer.join_game has not been implemented.'

  leave_game: (player) ->
    # Called when a player leaves this game. The leave cannot be canceled,
    # so this method should never throw an exception.
    console.log 'UGLIServer.leave_game has not been implemented.'

  start_game: ->
    # Called when the players leave the lobby and actually enter the game.
    # By default, this method does nothing.
