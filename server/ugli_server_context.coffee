# An UGLI server context is the first argument passed to the UGLI server each
# time any of the following methods are called:
#   initialize_state
#   handle_client_message
#   any UGLI callback
#
# The context stores the following data:
#   players: read-only mapping from user_id -> player currently in the game
#   state: mutable view of game state
#
# In addition, the context provides these UGLI framework helper methods:
#   setTimeout: (callback, delay) -> call callback after delay ms

class @UGLIServerContext
  @verbose = false

  constructor: (@_user_id_map, @state=null) ->
    @players = (player for user_id, player of @_user_id_map)
    @_timeouts = []

  setTimeout: (callback, delay) ->
    @_timeouts.push [callback, delay]

  _get_views: ->
    # This method is called by the framework after the game's server code
    # mutates this context state, but before this context is saved.
    #
    # Return a pair [user_views, public_view] of views. The user_views is a dict
    # mapping user_ids to their views, while the public view is totally visible.
    console.log('_get_views') if @verbose
    user_views = {}
    for user_id, player of @_user_id_map
      user_views[user_id] = Common.ugli_server.get_player_view @, player
    public_view = Common.ugli_server.get_public_view @
    [user_views, public_view]

  _add_user: (user) ->
    # Used to add users to a context if they successfully join a game.
    console.log('_add_user', user) if @verbose
    if user._id not of @_user_id_map
      @_user_id_map[user._id] = user.username
      @players.push user.username

  _remove_user: (user) ->
    # Used to remove users from a context if they leave a game.
    console.log('_remove_user', user) if @verbose
    if user._id of @_user_id_map
      delete @_user_id_map[user._id]
      @players = (player for player in @players if player != user.username)

  _after_save: (room_id) ->
    # This method is called by the framework after this context is successfully
    # saved. It launches any timeouts requested by the UGLI server.
    console.log('_after_save', room_id) if @verbose
    for [callback, delay] in @_timeouts
      Meteor.setTimeout (->
        UGLICore.call_state_mutator room_id, callback
      ), delay
    @_after_save = ->
      throw '_after_save called twice'