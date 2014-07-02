# This class stores in-memory state for a single room:
#   name: the room's name
#   game: an UGLI game server instance
#   users: a list of User objects currently in this room

class @Room
  constructor: (name, config, user) ->
    @users = []
    if name? or config? or user?
      @name = name
      @game = new (do Common.ugli_server)
      @summary = @game.initialize_state config
      @state = RoomState.WAITING
    else
      @name = Common.lobby_name
      @summary = false
      @game = false
      @state = RoomState.LOBBY
    @_id = Rooms.save_room @

  add_user: (user) ->
    assert (not @users.some user.conflicts), "Duplicate user: #{user}"
    user.set_room_id @_id, @state
    @users.push user
    Rooms.save_room @

  drop_user: (user) ->
    index = @users.indexOf user
    assert (index >= 0), "Missing user: #{user}"
    user.clear_room_id @_id, @state
    @users.splice index, 1
    Rooms.save_room @

  send_chat: (user, message) ->
    Chats.send_chat @_id, user.name, message

  @reset: ->
    Rooms.remove {}
    Chats.remove {}
