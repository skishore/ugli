# This class stores in-memory state for a single user:
#   name: the user's name
#   room_id: the id of the room the user is currently in
#   last_heartbeat: the last heartbeat ts

class @User
  constructor: (user_id) ->
    check user_id, String
    user = Meteor.users.findOne _id: user_id
    if not user?
      throw new UGLIPermissionsError "Invalid user_id: #{user_id}"
    @_id = user_id
    @name = user.username
    @room_id = null
    @wait_id = null
    @last_heartbeat = new Date().getTime()

  conflicts: (other) ->
    @_id == other._id or @name == other.name

  heartbeat: (user_id) ->
    @last_heartbeat = new Date().getTime()

  set_room_id: (room_id, state) ->
    field = if state == RoomState.WAITING then 'wait_id' else 'room_id'
    if @[field] != null
      throw new UGLIPermissionsError "room_id set: #{@[field]}"
    @[field] = room_id

  clear_room_id: (room_id, state) ->
    field = if state == RoomState.WAITING then 'wait_id' else 'room_id'
    if @[field] != room_id
      throw new UGLIPermissionsError "Incorrect room_id: #{@[field]}"
    @[field] = null
