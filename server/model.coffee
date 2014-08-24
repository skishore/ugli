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
      @["_commit_#{update.type}"] update

  _commit_create_room: (update) ->
    room = update.room
    room._id = Rooms.save_room room
    assert room._id?, "New room does not have an _id: #{room}"
    @rooms[room._id] = room

  _commit_update_room: (update) ->
    Rooms.save_room update.room

  _commit_delete_room: (update) ->
    Rooms.remove {_id: update.room._id}

  _commit_update_game: (update) ->
    Rooms.update_game update.room

  _commit_log_game_message: (update) ->
    Chats.send_chat update.room._id, '', update.message
