# This class stores in-memory state for a single room:
#   name: the room's name
#   game: an UGLI game server instance
#   players: list of names of players in the room

class @Room
  constructor: (name, game) ->
    if name? or game?
      throw new NotImplementedError 'Game rooms cannot be made yet!'
    else
      @name = Common.lobby_name
      @game = false
    @players = []
    @_id = Rooms.create_room @name, @game, @players

  add_user: (user) ->
    assert ((@players.indexOf user.name) == -1), "Duplicate user: #{@}, #{user}"
    assert user.room_id == null, "User is already assigned to a room: #{user}"
    user.room_id = @_id
    @players.push user.name
    do @players.sort
    do @save_state

  drop_user: (user) ->
    index = @players.indexOf user.name
    assert index >= 0, "Missing user: #{@}, #{user}"
    user.room_id = null
    @players.splice index, 1
    do @save_state

  publish: (user_id) ->
    fields = {name: 1, players: 1}
    result = [Chats.find {room_id: this._id}]
    if @game
      fields['game.public_view'] = 1
      fields["game.private_views.#{user_id}"] = 1
      result.push [Rooms.find {_id: this._id}, fields]
    else
      result.push Rooms.find {}, fields
    result

  save_state: ->
    Rooms.update_room @_id, @name, @game, @players

  @reset: ->
    Rooms.remove {}
    Chats.remove {}
