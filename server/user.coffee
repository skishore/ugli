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
    if state == RoomState.WAITING
      assert @wait_id == null, "User already waiting: #{@wait_id}"
      @wait_id = room_id
    else
      assert @room_id == null, "User already waiting: #{@room_id}"
      @room_id = room_id

  clear_room_id: (room_id, state) ->
    if state == RoomState.WAITING
      assert @wait_id == room_id, "Incorrect wait_id: #{@wait_id}"
      @wait_id = null
    else
      assert @room_id == room_id, "Incorrect room_id: #{@room_id}"
      @room_id = null
