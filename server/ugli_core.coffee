# TODO(karl): use this to wrap calls to server.on_client_message
class @UGLIContext
  constructor: (@user_ids, @rules, @state=null) ->
    @_timeouts = []

  setTimeout: (callback, delay) ->
    @_timeouts.push [callback, delay]

  # TODO(karl): maybe just move _get_views and _after_save logic
  # into UGLICore.call_state_mutator, since that's the only thing
  # that should be calling these (i think)

  _get_views: ->
    # called by framework after game server code mutates state
    console.log '_get_views'
    views = {}
    for user_id in @user_ids
      views[user_id] = Common.ugli_server.get_user_view @, user_id
    views

  _after_save: (room_id) ->
    # called by framework after state is successfully saved
    console.log '_after_save', arguments
    for [callback, delay] in @_timeouts
      Meteor.setTimeout(
        -> UGLICore.call_state_mutator room_id, callback
        delay
      )
    @_after_save = -> throw "_after_save called twice"

class @UGLICore
  @create_room_context: (room_id) ->
    console.log 'create_room_context', arguments
    room = Rooms.findOne _id: room_id
    if not room?
      throw "Room #{room_id} is not ready"
    game_state = GameStates.findOne _id: room?.game_state_id
    new UGLIContext room.user_ids, room.rules, game_state?.state

  @call_state_mutator = (room_id, callback) ->
    console.log 'call_state_mutator', room_id
    ctx = UGLICore.create_room_context room_id
    callback ctx
    views = ctx._get_views()
    if GameStates.update_game_state room_id, ctx.state, views
      ctx._after_save room_id

  @create_game: (user_id, rules) ->
    console.log 'create_game', arguments
    user = Users.findOne(_id: user_id)
    name = "#{user.username}'s game ##{Common.get_uid()}"
    room_id = Rooms.create_room name, [user_id], rules
    @call_state_mutator room_id, (context) ->
      Common.ugli_server.initialize_state context

  @on_client_message: (room_id, user_id, message) ->
    console.log 'on_client_message', arguments
    @call_state_mutator room_id, (context) ->
      Common.ugli_server.on_client_message context, user_id, message
