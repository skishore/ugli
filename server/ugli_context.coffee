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

class @UGLIContext
  @verbose = false

  constructor: (@_user_id_map, @state=null) ->
    @players = (player for user_id, player of @_user_id_map)
    @_timeouts = []

  setTimeout: (callback, delay) ->
    @_timeouts.push [callback, delay]

  # TODO(karl): maybe just move _get_views and _after_save logic
  # into UGLICore.call_state_mutator, since that's the only thing
  # that should be calling these (i think)

  _get_views: ->
    # Called by the framework after the game's server code mutates this
    # context's state. Returns the player-visible views of the state.
    console.log('_get_views') if @verbose
    views = {}
    for user_id, player of @_user_id_map
      views[user_id] = Common.ugli_server.get_player_view @, player
    views

  _after_save: (room_id) ->
    # Called by the framework after this context is successfully saved.
    console.log('_after_save', room_id) if @verbose
    for [callback, delay] in @_timeouts
      Meteor.setTimeout (->
        UGLICore.call_state_mutator room_id, callback
      ), delay
    @_after_save = ->
      throw '_after_save called twice'

  _add_user: (user) ->
    console.log('_add_user', user) if @verbose
    if user._id not of @_user_id_map
      @_user_id_map[user._id] = user.username
      @players.push user.username

  _remove_user: (user) ->
    console.log('_remove_user', user) if @verbose
    if user._id of @_user_id_map
      delete @_user_id_map[user._id]
      @players = (player for player in @players if player != user.username)
