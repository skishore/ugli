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
      @rooms[@lobby_id].drop_user user
      if user.room_id?
        @rooms[user.room_id].drop_user user

  get_user: (user_id) ->
    if user_id not of @users
      throw new UGLIPermissionsError 'User called method before being added!'
    @users[user_id]

  publish_chats: (user_id, room_id) ->
    Chats.publish @lobby_id, @users[user_id]?.room_id

  create_game: (user_id, config) ->
    game_room = @model.transaction =>
      user = @get_user user_id
      if user.room_id?
        throw new UGLIPermissionsError "Can't create a game while in one!"
      new Room @model, (do @room_names.get_unused_name), config
    @join_game user_id, game_room._id

  create_singleplayer_game: (user_id) ->
    game_room = @model.transaction =>
      user = @get_user user_id
      if user.room_id?
        @rooms[user.room_id].drop_user user, true
        user.room_id = null
      config = Common.singleplayer_config
      new Room @model, (do @room_names.get_unused_name), config, true
    @join_game user_id, game_room._id

  join_game: (user_id, room_id) ->
    @model.transaction =>
      user = @get_user user_id
      if user.room_id?
        throw new UGLIPermissionsError "Can't join a game while in one!"
      if room_id of @rooms and room_id != @lobby_id
        @rooms[room_id].add_user user
        user.room_id = room_id

  leave_game: (user_id, room_id, autoremove) ->
    @model.transaction =>
      user = @get_user user_id
      if room_id != user.room_id
        throw new UGLIPermissionsError "User can't leave game: #{room_id}"
      @rooms[room_id].drop_user user, autoremove
      user.room_id = null

  start_game: (user_id, room_id) ->
    @model.transaction =>
      user = @get_user user_id
      if room_id != user.room_id
        throw new UGLIPermissionsError "User can't start game: #{room_id}"
      do @rooms[room_id].start_game

  send_chat: (user_id, room_id, message) ->
    user = @get_user user_id
    if room_id != @lobby_id and room_id != user.room_id
      throw new UGLIPermissionsError "User can't send chat in room #{room_id}!"
    Chats.send_chat room_id, user.name, message

  send_game_message: (user_id, room_id, message) ->
    @model.transaction =>
      user = @get_user user_id
      if room_id != user.room_id
        throw new UGLIPermissionsError "User isn't in game in room #{room_id}!"
      room = @rooms[room_id]
      if room.state != RoomState.PLAYING
        throw new UGLIPermissionsError "Can't play in #{room.state} game"
      room.game.handle_message user.name, message
      @model.update_game room
