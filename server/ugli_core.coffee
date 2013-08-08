# TODO(skishore): Implement an UGLI context class.
# TODO(skishore): Implement a timeout object with time_left() and cancel().

class @UGLICore
  @create_ugli_context: (room_id) ->
    console.log 'create_ugli_context'
    room = Rooms.findOne(_id: room_id)
    game_state = GameStates.findOne(_id: room?.game_state_id)
    if not room or not game_state
      throw "Room #{room_id} is not ready"
    {
      user_ids: room.user_ids,
      rules: room.rules,
      state: game_state.state,
      setTimeout: Meteor.setTimeout,
    }

  @create_initial_context: (user_id, rules) ->
    console.log 'create_initial_context'
    {
      user_ids: [user_id],
      rules: rules,
      state: null,
      setTimeout: Meteor.setTimeout,
    }

  @get_views: (context) ->
    console.log 'get_views'
    views = {}
    for user_id in context.user_ids
      views[user_id] = Common.ugli_server.get_user_view context, user_id
    views

  @create_game: (user_id, rules) ->
    console.log 'create_game'
    user = Users.findOne(_id: user_id)
    name = "#{user.username}'s game ##{Common.get_uid()}"
    context = @create_initial_context user_id, rules
    Common.ugli_server.initialize_state context
    views = @get_views context
    GameStates.create_game user_id, name, rules, context.state, views
