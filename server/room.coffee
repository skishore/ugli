# This class stores in-memory state for a single room:
#   name: the room's name
#   game: an UGLI game server instance
#   users: a list of User objects currently in this room

class @Room
  constructor: (@model, name, config, user) ->
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
    do @set_id_field_for_state
    @model.create_room @

  set_id_field_for_state: ->
    @id_field = if @state == RoomState.WAITING then 'wait_id' else 'room_id'

  add_user: (user) ->
    assert (not @users.some user.conflicts), "Duplicate user: #{user}"
    assert user[@id_field] == null, "#{@id_field} set: #{user[@id_field]}"
    @game.join_game user.name if @game
    @users.push user
    user[@id_field] = @_id
    @model.update_room @

  drop_user: (user) ->
    index = @users.indexOf user
    assert (index >= 0), "Missing user: #{user}"
    assert user[@id_field] == @_id, "Incorrect #{@id_field}: #{user[@id_field]}"
    @game.leave_game user.name if @game
    @users.splice index, 1
    user[@id_field] = null
    if @users.length == 0 and @state != RoomState.LOBBY
      @model.delete_room @
    else
      @model.update_room @
