class @Model
  constructor: (@rooms, @room_names, @singleplayer_rooms) ->
    Rooms.remove {}
    Chats.remove {}
    do Chats.set_cleanup_timer
    @_updates = []
    @_num_updates = 0
    @_updated_room_ids = {}
    @_updated_game_ids = {}

  transaction: (callback) ->
    result = Meteor._noYieldsAllowed callback
    do @_commit
    result

  create_room: (room) ->
    assert not room._id?, "Tried to create room with _id: #{room}"
    @_updates.push {type: 'create_room', room: room}
    @_num_updates += 1

  update_room: (room) ->
    assert room._id?, "Tried to save room without _id: #{room}"
    if not @_updated_room_ids[room._id]?
      @_updates.push {type: 'update_room', room: room}
      @_num_updates += 1
      @_updated_room_ids[room._id] = true

  delete_room: (room) ->
    assert room._id of @rooms, "Missing room_id: #{room}"
    assert room.users.length == 0, "Tried to delete non-empty room: #{room}"
    delete @rooms[room._id]
    if room.multiplayer
      @room_names.free_name room.name
    else if room.singleplayer_id?
      delete @singleplayer_rooms[room.singleplayer_id]
    @_updates.push {type: 'delete_room', room: room}
    @_num_updates += 1

  update_game: (room) ->
    assert room._id? and room.game
    if not @_updated_game_ids[room._id]?
      @_updates.push {type: 'update_game', room: room}
      @_num_updates += 1
      @_updated_game_ids[room._id] = true

  log_game_message: (room, message) ->
    assert room._id of @rooms, "Missing room_id: #{room}"
    assert room.game, 'Logged a game message from a room missing an _id!'
    @_updates.push {type: 'log_game_message', room: room, message: message}
    @_num_updates += 1

  _commit: ->
    # Applying updates in the order in which they were called is tricky,
    # because Meteor will yield each time we make a model call, during which
    # time more updates could be pushed on the queue. We get around this by
    # making each call to commit responsible for applying the correct number
    # of updates, although it could apply updates from other transactions.
    num_updates = @_num_updates
    @_num_updates = 0
    @_updated_room_ids = {}
    @_updated_game_ids = {}
    for i in [0...num_updates]
      update = do @_updates.shift
      type = update.type
      room = update.room
      if type == 'create_room'
        room._id = Rooms.save_room room
        assert room._id?, "Created room does not have an _id: #{room}"
        @rooms[room._id] = room
      else if type == 'update_room'
        Rooms.save_room room
      else if type == 'delete_room'
        Rooms.remove {_id: room._id}
      else if type == 'update_game'
        Rooms.update_game room
      else if type == 'log_game_message'
        Chats.send_chat room._id, '', update.message
      else
        assert false, "Invalid update type: #{type}"
