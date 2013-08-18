# An implementation of UGLIServer should override the following methods:
#   initialize_state: (config) ->
#   get_player_view: (config) -> view
#   get_public_view: (config) -> view
#   handle_message: (player, message) ->
#   join_game: (player) -> accepted
#   leave_game: (player) ->
# See below for detailed specifications for these methods.

class @UGLIServer
  constructor: (config) ->
    @players = {}
    @state = {}
    @initialize_state config

  setTimeout: (callback, delay) ->
    throw NotImplementedError 'UGLIServer.setTimeout'

  clearTimeout: (timeout) ->
    throw NotImplementedError 'UGLIServer.clearTimeout'

  _get_views: ->
    # Returns a pair [user_views, public_view] of views. user_views is a dict
    # mapping user_ids to their views while public_view is visible to all.
    user_views = {}
    for player, user_id of @ugli.players
      user_views[user_id] = @get_player_view player
    public_view @get_public_view()
    [user_views, public_view]

  _add_user: (user) ->
    # Called by the framework to add a user if he is accepted by join_game.
    @players[user.username] = user._id

  _remove_user: (user) ->
    # Called by the framework to remove a user if they leave the game's room.
    delete @players[user.username]

  '''
  Interface methods follow. To write a new game, override these methods.
  '''

  initialize_state: (config) ->
    # Initialize @state based on config, or throw if it is invalid.
    console.log 'UGLIServer.constructor has not been implemented.'

  get_player_view: (player) ->
    # Return the view of the game that the given player should see right now.
    #
    # The default implementation makes the entire state visible.
    return @ugli.state

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
    # Called when a new player wants to join the game. Returns true if the
    # player should be allowed to join.
    #
    # By default, all requests to join are accepted.
    return true

  leave_game: (player) ->
    # Called when a player leaves a game. The leave cannot be canceled.
    console.log 'UGLIServer.leave_game has not been implemented.'
