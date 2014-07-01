# This class stores in-memory state for a single room:
#   name: the room's name
#   game: an UGLI game server instance
#   users: a list of User objects currently in this room

class @Room
  constructor: (name, game) ->
    if name? or game?
      throw new NotImplementedError 'Game rooms cannot be made yet!'
    else
      @name = Common.lobby_name
      @game = false
    @_id = do Rooms.create_lobby
    @users = []

  add_user: (user) ->
    assert (not @users.some user.conflicts), "Duplicate user: #{@}, #{user}"
    assert user.room_id == null, "User already in a room: #{user}"
    user.room_id = @_id
    @users.push user
    do @save_state

  drop_user: (user) ->
    index = @users.indexOf user
    assert index >= 0, "User not in this room: #{@}, #{user}"
    user.room_id = null
    @users.splice index, 1
    do @save_state

  send_chat: (user, message) ->
    Chats.send_chat @_id, user.name, message

  save_state: ->
    Rooms.update_room @_id, @name, @game, @users

  @reset: ->
    Rooms.remove {}
    Chats.remove {}
