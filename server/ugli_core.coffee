# UGLI server state maintained in memory to allow for atomic updates.
#   users: dict mapping user_id -> User instances
#   rooms: dict mapping game_id -> Room instances
#   lobby_id: the id of the lobby room
#   room_names: instance of a RoomNames object that stores free names

class @UGLICore
  constructor: ->
    do Room.reset
    @users = {}
    @rooms = {}
    lobby = new Room
    @rooms[lobby._id] = lobby
    @lobby_id = lobby._id
    @room_names = new RoomNames

  get_user_and_room: (user_id) ->
    if user_id not of @users
      @users[user_id] = new User user_id
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
    if room._id != @lobby_id
      throw new UGLIPermissionsError "Can only create a game from the lobby!"
    if user.wait_id?
      throw new UGLIPermissionsError "Can't create a game while waiting on one!"
    game_room = new Room (do @room_names.get_unused_name), config
    @rooms[game_room._id] = game_room
    game_room.add_user user

  join_game: (user_id, room_id) ->
    [user, room] = @get_user_and_room user_id
    if room._id != @lobby_id
      throw new UGLIPermissionsError "Can only join a game from the lobby!"
    if room_id of @rooms and room_id != @lobby_id
      @rooms[room_id].add_user user

  leave_game: (user_id, room_id) ->
    [user, room] = @get_user_and_room user_id
    if room_id of @rooms and room_id != @lobby_id
      @drop_user_from_room user, room_id

  send_chat: (user_id, room_id, message) ->
    [user, room] = @get_user_and_room user_id
    if room_id == room._id
      room.send_chat user, message

  mark_idle_users: (timeout) ->
    cutoff = new Date().getTime() - timeout
    idle_users = (user for _, user of @users when user.last_heartbeat < cutoff)
    for user in idle_users
      delete @users[user._id]
      @drop_user_from_room user, user.room_id, true
      @drop_user_from_room user, user.wait_id, true

  drop_user_from_room: (user, room_id, force) ->
    if room_id of @rooms
      @rooms[room_id].drop_user user
      if @rooms[room_id]?.users.length == 0 and room_id != @lobby_id
        delete @rooms[room_id]
        Rooms.remove {_id: room_id}
