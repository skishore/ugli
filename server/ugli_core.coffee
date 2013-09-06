class @UGLICore
  # A dict mapping room_id -> game server instances. Updated in-memory.
  @games = {}

  @call_state_mutator = (room_id, callback, post_callback) ->
    # Call a function that updates the state of the game in room room_id.
    # This callback should NEVER yield.
    #
    # The caller may optionally specify a post_callback that will be called
    # after the atomic state update is made but before the state is saved.
    game = @games[room_id]
    Meteor._noYieldsAllowed =>
      callback game
      game._index += 1
    post_callback() if post_callback
    if game?
      GameStates.save_state room_id, game

  @create_game: (user_id, config) ->
    user = Users.get user_id
    if not user?
      throw new UGLIPermissionsError "Logged-out users can't create games."
    game = new (Common.ugli_server())()
    game.initialize_state config
    # Create a room to run the new game in and have the user join it.
    name = "#{user.username}'s game ##{Common.get_random_id()}"
    room_id = Rooms.create_room name, true
    @games[room_id] = game
    Rooms.join_room user_id, room_id

  @handle_message: (user_id, room_id, message) ->
    user = Users.get user_id
    @call_state_mutator room_id, (game) ->
      if not game? or user?.username not of game.players
        throw new UGLIPermissionsError "User #{user_id} not in game #{room_id}."
      game.handle_update user.username, message

  @save_latest_states: ->
    current_states = GameStates.get_current_states
    for room_id, game_state in current_states
      if game_state.index < @games[room_id]?.index
        console.log "Got lagging game state: #{room_id}: #{game_state}"
        GameStates.save_state room_id, @games[room_id]
