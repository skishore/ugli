# TODO(karl): use this to wrap calls to server.on_client_message
class @UGLIContext
  constructor: (@user_ids, @rules, @state=null) ->
    @_timeouts = []

  setTimeout: (callback, delay) ->
    @_timeouts.push [callback, delay]

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
    console.log 'create_room_context'
    room = Rooms.findOne _id: room_id
    if not room
      throw "Room #{room_id} is not ready"
    game_state = GameStates.findOne _id: room?.game_state_id
    new UGLIContext room.user_ids, room.rules, game_state?.state

  @call_state_mutator = (room_id, callback) ->
    ctx = UGLICore.create_room_context room_id
    callback ctx
    if GameStates.update_game_state room_id, ctx.state, ctx._get_views()
      ctx._after_save room_id

  @create_game: (user_id, rules) ->
    console.log 'create_game'
    user = Users.findOne(_id: user_id)
    name = "#{user.username}'s game ##{Common.get_uid()}"
    room_id = Rooms.create_room name, [user_id], rules
    @call_state_mutator room_id, (context) ->
        Common.ugli_server.initialize_state context
