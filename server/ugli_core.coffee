class @UGLICore
  @verbose = false

  @create_room_context: (room_id) ->
    console.log('create_room_context', room_id) if @verbose
    room = Rooms.findOne _id: room_id
    if not room?
      throw "Room #{room_id} is not ready"
    game_state = GameStates.findOne _id: room?.game_state_id
    new UGLIContext room.user_ids, room.rules, game_state?.state

  @call_state_mutator = (room_id, callback) ->
    console.log('call_state_mutator', room_id) if @verbose
    ctx = UGLICore.create_room_context room_id
    callback ctx
    views = ctx._get_views()
    if GameStates.update_game_state room_id, ctx.state, views
      ctx._after_save room_id

  @create_game: (user_id, rules) ->
    console.log('create_game', user_id, rules) if @verbose
    user = Users.findOne(_id: user_id)
    name = "#{user.username}'s game ##{Common.get_uid()}"
    room_id = Rooms.create_room name, [user_id], rules
    @call_state_mutator room_id, (context) ->
      Common.ugli_server.initialize_state context

  @handle_client_message: (room_id, user_id, message) ->
    console.log('handle_client_message', room_id, user_id, message) if @verbose
    @call_state_mutator room_id, (context) ->
      Common.ugli_server.handle_client_message context, user_id, message
