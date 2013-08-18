class @UGLICore
  # A dict mapping room_id -> game server instances. Updated in-memory.
  @games = {}

  @call_state_mutator = (room_id, callback) ->
    # Call a function that updates context.state. Return true if the new state
    # was successfully saved to the database.
    [context, index] = UGLICore.create_room_context room_id
    callback context
    GameStates.save_context room_id, index, context

  @create_game: (user_id, config) ->
    user = Users.get user_id
    if not user?
      throw UGLIPermissionsError "Logged-out users can't create games."
    # Initialize a game server with the given config, or throw if it invalid.
    game = new Common.ugli_server() config
    # Create a room to run the new game in and have the user join it.
    name = "#{user.username}'s game ##{Common.get_random_id()}"
    room_id = Rooms.create_room name, true
    @games[room_id] = game
    Rooms.join_room user_id, room_id

  @handle_message: (user_id, room_id, message) ->
    user = Users.get user_id
    game = @games[room_id]
    if not game? or user?.username not of game.ugli.players
    if user? and room? and user._id in room.user_ids
      # TODO(skishore): Damn it, this shit is totally wrong
      @call_state_mutator room_id, (context) ->
        #Common.ugli_server.handle_message context, user.username, message
