# This class stores in-memory state for a single user:
#   name: the user's name
#   room_id: the id of the room the user is currently in
#   last_heartbeat: the last heartbeat ts

class @User
  constructor: (user) ->
    @_id = user._id
    @name = user.username
    @room_id = null

  conflicts: (other) ->
    @_id == other._id or @name == other.name
