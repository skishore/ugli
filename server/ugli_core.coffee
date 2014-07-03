# UGLI server state maintained in memory to allow for atomic updates.
#   users: dict mapping user_id -> User instances
#   rooms: dict mapping game_id -> Room instances
#   room_names: instance of RoomNames that stores free names
#   model: instance of a Model used for transactionality
#   lobby_id: the id of the lobby room
# An UGLICore instance should never modify the @rooms dict directly. Instead,
# rooms will be created or dropped by the Model. @rooms can be read, though.

class @UGLICore
  constructor: ->
    @users = {}
    @rooms = {}
    @room_names = new RoomNames
    @model = new Model @rooms, @room_names
    # Create the lobby and record its _id.
    @lobby_id = (@model.transaction => new Room @model)._id
    assert @lobby_id?, 'Failed to get a lobby_id!'

  add_user: (db_user) ->
    @model.transaction =>
      if db_user._id of @users
        throw new UGLIPermissionsError 'User added before being dropped!'
      @users[db_user._id] = new User db_user
      @rooms[@lobby_id].add_user @users[db_user._id]

  drop_user: (db_user) ->
    @model.transaction =>
      if db_user._id not of @users
        throw new UGLIPermissionsError 'User dropped before being added!'
      user = @users[db_user._id]
      delete @users[db_user._id]
      if user.room_id?
        @rooms[user.room_id].drop_user user
      if user.wait_id?
        @rooms[user.wait_id].drop_user user

  get_user_and_room: (user_id, user) ->
    if user_id not of @users
      throw new UGLIPermissionsError 'User called method before being added!'
    user = @users[user_id]
    assert user.room_id of @rooms, "Orphaned user: #{user}"
    [user, @rooms[user.room_id]]

  publish_chats: (user_id, room_id) ->
    Chats.publish @users[user_id]?.room_id

  create_game: (user_id, config) ->
    game_room = @model.transaction =>
      [user, room] = @get_user_and_room user_id
      if room._id != @lobby_id
        throw new UGLIPermissionsError 'Can only create a game from the lobby!'
      if user.wait_id?
        throw new UGLIPermissionsError "Can't create a game while waiting!"
      new Room @model, (do @room_names.get_unused_name), config
    @join_game user_id, game_room._id

  join_game: (user_id, room_id) ->
    @model.transaction =>
      [user, room] = @get_user_and_room user_id
      if room._id != @lobby_id
        throw new UGLIPermissionsError 'Can only join a game from the lobby!'
      if room_id of @rooms and room_id != @lobby_id
        room = @rooms[room_id]
        if room.state == RoomState.PLAYING
          @rooms[room_id].swap_user user, @rooms[@lobby_id]
        else
          @rooms[room_id].add_user user

  leave_game: (user_id, room_id, autoremove) ->
    @model.transaction =>
      [user, room] = @get_user_and_room user_id
      if room_id not of @rooms or room_id == @lobby_id
        throw new UGLIPermissionsError "User can't leave room: #{room_id}"
      @rooms[room_id].drop_user user, autoremove
      if user.room_id == null
        @rooms[@lobby_id].add_user user

  start_game: (user_id, room_id) ->
    @model.transaction =>
      [user, room] = @get_user_and_room user_id
      if room_id != user.wait_id
        throw new UGLIPermissionsError 'Can only start a WAITING game!'
      game_room = @rooms[user.wait_id]
      for other in game_room.users
        @rooms[other.room_id].drop_user other
      do game_room.start_game

  send_chat: (user_id, room_id, message) ->
    [user, room] = @get_user_and_room user_id
    if room_id != room._id
      throw new UGLIPermissionsError "User can't send chat in room #{room_id}!"
    Chats.send_chat room_id, user.name, message

  send_game_message: (user_id, room_id, message) ->
    @model.transaction =>
      [user, room] = @get_user_and_room user_id
      if room_id != room._id or room.state != RoomState.PLAYING
        throw new UGLIPermissionsError "User isn't in game in room #{room_id}!"
      room.game.handle_message user.name, message
      @model.update_room room
