# An UGLI server context is the first argument passed to the UGLI server each
# time any of the following methods are called:
#   initialize_state
#   handle_client_message
#   any UGLI callback
#
# The context stores the following data, which is read-only except for state:
#   usernames: list of users currently in the game
#   rules: the game's rules dictionary
#   state: complete server view of game state
#
# In addition, the context provides these UGLI framework helper methods:
#   setTimeout: (callback, delay) -> call callback after delay ms

# TODO(skishore): this context should store usernames instead of (or in addition to) user_ids
# TODO(skishore): After we have join/leave notification this context should check for missed joins/leaves and notify

# TODO(skishore): race condition! this context should store the initial state of the room and pass it to update game state. right now the update is super-racy...!!!!

class @UGLIContext
  @verbose = false

  constructor: (@user_ids, @rules, @state=null) ->
    @_timeouts = []

  setTimeout: (callback, delay) ->
    @_timeouts.push [callback, delay]

  # TODO(karl): maybe just move _get_views and _after_save logic
  # into UGLICore.call_state_mutator, since that's the only thing
  # that should be calling these (i think)

  _get_views: ->
    # Called by the framework after the game's server code mutates this
    # context's state.
    console.log('_get_views') if @verbose
    views = {}
    for user_id in @user_ids
      views[user_id] = Common.ugli_server.get_user_view @, user_id
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
