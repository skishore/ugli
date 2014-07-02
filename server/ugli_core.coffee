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
    lobby = @model.transaction =>
      new Room @model
    @lobby_id = lobby._id

  get_user_and_room: (user_id) ->
    if user_id not of @users
      @users[user_id] = new User user_id
      @model.transaction =>
        @rooms[@lobby_id].add_user @users[user_id]
    user = @users[user_id]
    assert user.room_id of @rooms, "Orphaned user: #{user}"
    [user, @rooms[user.room_id]]

  publish_chats: (user_id, room_id) ->
    # Ignores the room_id and returns chats for the user's current room.
    [user, room] = @get_user_and_room user_id
    Chats.publish room._id

  heartbeat: (user_id) ->
    [user, room] = @get_user_and_room user_id
    do user.heartbeat

  create_game: (user_id, config) ->
    [user, room] = @get_user_and_room user_id
    game_room = @model.transaction =>
      if room._id != @lobby_id
        throw new UGLIPermissionsError "Can only create a game from the lobby!"
      if user.wait_id?
        throw new UGLIPermissionsError "Can't create a game while waiting!"
      new Room @model, (do @room_names.get_unused_name), config
    @join_game user_id, game_room._id

  join_game: (user_id, room_id) ->
    [user, room] = @get_user_and_room user_id
    @model.transaction =>
      if room._id != @lobby_id
        throw new UGLIPermissionsError "Can only join a game from the lobby!"
      if room_id of @rooms and room_id != @lobby_id
        @rooms[room_id].add_user user

  leave_game: (user_id, room_id) ->
    [user, room] = @get_user_and_room user_id
    @model.transaction =>
      if room_id of @rooms and room_id != @lobby_id
        @rooms[room_id].drop_user user

  send_chat: (user_id, room_id, message) ->
    [user, room] = @get_user_and_room user_id
    if room_id == room._id
      Chats.send_chat room_id, user.name, message

  mark_idle_users: (timeout) ->
    @model.transaction =>
      ts = new Date().getTime() - timeout
      idle_users = (user for _, user of @users when user.last_heartbeat < ts)
      for user in idle_users
        delete @users[user._id]
        if user.room_id of @rooms
          @rooms[user.room_id].drop_user user
        if user.wait_id of @rooms
          @rooms[user.wait_id].drop_user user
