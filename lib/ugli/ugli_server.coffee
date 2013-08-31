# An instance of UGLIServer stores the following data about the game:
#   @players: map from current player names -> _ids
#   @state: fully-specified mutable game state
#
# An implementation of UGLIServer should override the following methods:
#   initialize_state: (config) ->
#   get_player_view: (config) -> view
#   get_public_view: (config) -> view
#   handle_message: (player, message) ->
#   join_game: (player) -> accepted
#   leave_game: (player) ->
# See below for detailed specifications for these methods.

class @UGLIServer
  constructor: (_index, players, state) ->
    @_index = _index or 0
    @players = players or {}
    @state = state or {}

  setTimeout: (callback, delay) ->
    throw new NotImplementedError 'UGLIServer.setTimeout'

  clearTimeout: (timeout) ->
    throw new NotImplementedError 'UGLIServer.clearTimeout'

  _get_views: ->
    # Return a pair [user_views, public_view] of views. user_views is a dict
    # mapping user_ids to their views while public_view is visible to all.
    user_views = {}
    for player, user_id of @players
      user_views[user_id] = @get_player_view player
    public_view = @get_public_view()
    [user_views, public_view]

  _add_user: (user) ->
    # Called by the framework to add a user if he is accepted by join_game.
    @join_game user.username
    @players[user.username] = user._id

  _remove_user: (user) ->
    # Called by the framework to remove a user if they leave the game's room.
    @leave_game user.username
    delete @players[user.username]

  '''
  Server interface methods follow. To write a new game, override these methods.
  '''

  initialize_state: (config) ->
    # Initialize @state based on config, or throw an UGLIClientError if config
    # is invalid.
    console.log 'UGLIServer.constructor has not been implemented.'

  get_player_view: (player) ->
    # Return the view of the game that the given player should see right now.
    #
    # The default implementation makes the entire state visible.
    return @state

  get_public_view: ->
    # Return the view of the game that users in the lobby should see. Certain
    # attributes of this view are handled specially:
    #   open: bool - used to determine whether the join buttons are enabled
    #
    # The default implementation sets open to true.
    return open: true

  handle_message: (player, message) ->
    # Called when a client calls @ugli.send message.
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
