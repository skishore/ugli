# TODO(skishore): Implement an UGLI context class.
# TODO(skishore): Implement a timeout object with time_left() and cancel().

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

  _commit: (room_id) ->
    # called by framework after state is saved
    console.log '_commit'
    for [callback, delay] in @_timeouts
      Meteor.setTimeout(
        -> callback UGLICore.create_ugli_context room_id
        delay
      )
    @_timeouts = []

class @UGLICore
  @create_ugli_context: (room_id) ->
    console.log 'create_ugli_context'
    room = Rooms.findOne(_id: room_id)
    game_state = GameStates.findOne(_id: room?.game_state_id)
    if not room or not game_state
      throw "Room #{room_id} is not ready"
    new UGLIContext room.user_ids, room.rules, game_state.state

  @create_initial_context: (user_id, rules) ->
    console.log 'create_initial_context'
    new UGLIContext [user_id], rules

  @create_game: (user_id, rules) ->
    console.log 'create_game'
    user = Users.findOne(_id: user_id)
    name = "#{user.username}'s game ##{Common.get_uid()}"
    context = @create_initial_context user_id, rules
    Common.ugli_server.initialize_state context
    views = context._get_views()
    room_id = GameStates.create_game user_id, name, rules, context.state, views
    if room_id?
      context._commit room_id
