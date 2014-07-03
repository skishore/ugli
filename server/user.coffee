# This class stores in-memory state for a single user:
#   name: the user's name
#   room_id: the id of the room the user is currently in
#   last_heartbeat: the last heartbeat ts

class @User
  constructor: (user) ->
    @_id = user._id
    @name = user.username
    @room_id = null
    @wait_id = null

  conflicts: (other) ->
    @_id == other._id or @name == other.name

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
