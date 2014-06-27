# UGLI server state maintained in memory to allow for atomic updates.
#   users: dict mapping user_id -> User instances
#   rooms: dict mapping game_id -> Room instances
#   lobby_id: the id of the lobby room

class @UGLICore
  constructor: ->
    do Room.reset
    @users = {}
    @rooms = {}
    lobby = new Room
    @rooms[lobby._id] = lobby
    @lobby_id = lobby._id

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

  send_chat: (user_id, room_id, message) ->
    [user, room] = @get_user_and_room user_id
    if room_id == room._id
      room.send_chat user, message

  mark_idle_users: (timeout) ->
    cutoff = new Date().getTime() - timeout
    idle_users = (user for _, user of @users when user.last_heartbeat < cutoff)
    for user in idle_users
      delete @users[user._id]
      @rooms[user.room_id].drop_user user
