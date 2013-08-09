class @UGLICore
  @verbose = false

  @create_room_context: (room_id) ->
    # Return a [context, index] pair. The index is the current state index.
    console.log('create_room_context', room_id) if @verbose
    # Check that the room exists and get the list of players.
    room = Rooms.get room_id
    if not room?
      throw "Room #{room_id} is not ready"
    users = Users.find(_id: $in: room.user_ids).fetch()
    if users.length != room.user_ids.length
      throw "Missing users w/ user_ids in #{room.user_ids}"
    user_id_map = {}
    for user in users
      user_id_map[user._id] = user.username
    # Get the mutable game state and return it.
    game_state = GameStates.get_current_state room_id
    [
      new UGLIServerContext user_id_map, game_state?.state ? {}
      if game_state? then game_state.index else -1
    ]

  @call_state_mutator = (room_id, callback) ->
    console.log('call_state_mutator', room_id) if @verbose
    [context, index] = UGLICore.create_room_context room_id
    callback context
    if GameStates.save_context room_id, index, context
      context._after_save room_id

  @create_game: (user_id, config) ->
    console.log('create_game', user_id, config) if @verbose
    user = Users.get user_id
    name = "#{user.username}'s game ##{Common.get_uid()}"
    room_id = Rooms.create_room name, true
    @call_state_mutator room_id, (context) ->
      Common.ugli_server.initialize_state context, config
    Rooms.join_room user_id, room_id

  @handle_client_message: (user_id, room_id, message) ->
    console.log('handle_client_message', user_id, room_id, message) if @verbose
    user = Users.get user_id
    room = Rooms.get room_id
    if user? and room? and user._id in room.user_ids
      @call_state_mutator room_id, (context) ->
        Common.ugli_server.handle_client_message context, user.username, message
