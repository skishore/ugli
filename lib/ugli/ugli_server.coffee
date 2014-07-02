# An instance of UGLIServer stores the following data about the game:
#   @state: fully-specified, mutable game state
#
# An implementation of UGLIServer should override the following methods:
#   initialize_state: (config) -> summary
#   get_player_view: (config) -> view
#   get_public_view: (config) -> view
#   handle_message: (player, message) ->
#   join_game: (player) -> accepted
#   leave_game: (player) ->
# See below for detailed specifications for these methods.

class @UGLIServer
  constructor: () ->
    @state = {}

  _get_views: (users) ->
    private_views = {}
    for user_id, user of users
      private_views[user_id] = @get_player_view user.name
    {private_views: private_views, public_view: do @get_public_view}

  setTimeout: (callback, delay) ->
    throw new NotImplementedError 'UGLIServer.setTimeout'

  clearTimeout: (timeout) ->
    throw new NotImplementedError 'UGLIServer.clearTimeout'

  '''
  Server interface methods follow. To write a new game, override these methods.
  '''

  initialize_state: (config) ->
    # Initialize @state based on config, or throw an UGLIClientError if config
    # is invalid. If the config is valid, this method should return a summary
    # dict with the following keys:
    #   description: a short description of the game mode (eg, 'Sprint')
    #   explanation: a longer explanation of the game mode
    #   max_players: the maximum number of players allowed in the game
    console.log 'UGLIServer.constructor has not been implemented.'

  get_player_view: (player) ->
    # Return data about the state that is only visible to the given player.
    #
    # The final view for a player is the public view extended by the private
    # view - that is, the value of shared keys are taken from the private view.
    #
    # By default, there is no per-player hidden information.
    return {}

  get_public_view: ->
    # Return data about the state that is visible to all players.
    #
    # The default implementation makes the entire state visible.
    return @state

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
