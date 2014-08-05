# This class stores in-memory state for a single room:
#   name: the room's name
#   game: an UGLI game server instance
#   users: a list of User objects currently in this room

class @Room
  constructor: (@model, name, config, singleplayer_id) ->
    @users = []
    if name? or config? or singleplayer_id?
      @name = name
      @game = new (do Common.ugli_server) @, config
      @multiplayer = not singleplayer_id?
      @singleplayer_id = singleplayer_id if singleplayer_id?
      @state = RoomState.WAITING
    else
      @name = 'Lobby'
      @summary = false
      @game = false
      @multiplayer = false
      @state = RoomState.LOBBY
    @model.create_room @

  add_user: (user) ->
    assert (not @users.some user.conflicts), "Duplicate user: #{user}"
    @game.join_game user.name if @game
    if @state == RoomState.WAITING and not @multiplayer
      @state = RoomState.PLAYING
    @users.push user
    @model.update_room @

  drop_user: (user, autoremove) ->
    index = @users.indexOf user
    assert (index >= 0), "Missing user: #{user}"
    @game.leave_game user.name if @game
    @users.splice index, 1
    if @game and @users.length == 0
      if !!autoremove
        @model.delete_room @
      else
        @state = RoomState.WAITING
        @model.update_room @
    else
      @model.update_room @

  start_game: ->
    if @state != RoomState.WAITING
      throw new UGLIPermissionsError "Can't start a #{@state} game!"
    @state = RoomState.PLAYING
    @model.update_room @
