# This class stores in-memory state for a single room:
#   name: the room's name
#   game: an UGLI game server instance
#   users: a list of User objects currently in this room

class @Room
  constructor: (@model, name, config, user) ->
    @users = []
    if name? or config? or user?
      @name = name
      @game = new (do Common.ugli_server) @
      @summary = @game.initialize_state config
      @set_state RoomState.WAITING
    else
      @name = 'Lobby'
      @summary = false
      @game = false
      @set_state RoomState.LOBBY
    @model.create_room @

  set_state: (state) ->
    @state = state
    @id_field = if @state == RoomState.WAITING then 'wait_id' else 'room_id'

  add_user: (user) ->
    assert (not @users.some user.conflicts), "Duplicate user: #{user}"
    assert user[@id_field] == null, "#{@id_field} set: #{user[@id_field]}"
    @game.join_game user.name if @game
    @users.push user
    user[@id_field] = @_id
    @model.update_room @

  drop_user: (user, autoremove) ->
    index = @users.indexOf user
    assert (index >= 0), "Missing user: #{user}"
    assert user[@id_field] == @_id, "Incorrect #{@id_field}: #{user[@id_field]}"
    @game.leave_game user.name if @game
    @users.splice index, 1
    user[@id_field] = null
    if @users.length == 0 and @state != RoomState.LOBBY
      if !!autoremove
        @model.delete_room @
      else
        @set_state RoomState.WAITING
        @model.update_room @
    else
      @model.update_room @

  swap_user: (user, other_room) ->
    assert (not @users.some user.conflicts), "Duplicate user: #{user}"
    assert (user.room_id  == other_room._id) and not user.wait_id?
    # Call join_game first to give the UGLIServer a chance to reject the user.
    @game.join_game user.name if @game
    # Rely on the lazy update of the model. This update will go through before
    # the update that drops the user from the other room, but after the other edits.
    @model.update_room @
    # Drop the user from the other room and add it to this one.
    other_room.drop_user user
    @users.push user
    user[@id_field] = @_id

  start_game: ->
    assert @game and @state == RoomState.WAITING
    for user in @users
      assert user.room_id == null and user.wait_id == @_id
    for user in @users
      user.room_id = @_id
      user.wait_id = null
    @set_state RoomState.PLAYING
    @model.update_room @
