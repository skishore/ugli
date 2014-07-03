class @Model
  constructor: (@rooms, @room_names) ->
    Rooms.remove {}
    Chats.remove {}
    @_updates = []
    @_num_updates = 0

  transaction: (callback) ->
    result = Meteor._noYieldsAllowed callback
    do @_commit
    result

  create_room: (room) ->
    assert not room._id?, "Tried to create room with _id: #{room}"
    @_updates.push ['create', room]
    @_num_updates += 1

  update_room: (room) ->
    assert room._id?, "Tried to save room without _id: #{room}"
    @_updates.push ['update', room]
    @_num_updates += 1

  delete_room: (room) ->
    assert room._id of @rooms, "Missing room_id: #{room}"
    assert room.users.length == 0, "Tried to delete non-empty room: #{room}"
    delete @rooms[room._id]
    @room_names.free_name room.name
    @_updates.push ['delete', room]
    @_num_updates += 1

  _commit: ->
    # Applying updates in the order in which they were called is tricky,
    # because Meteor will yield each time we make a model call, during which
    # time more updates could be pushed on the queue. We get around this by
    # making each call to commit responsible for applying the correct number
    # of updates, although it could apply updates from other transactions.
    num_updates = @_num_updates
    @_num_updates = 0
    for i in [0...num_updates]
      [type, room] = do @_updates.shift
      if type == 'create'
        room._id = Rooms.save_room room
        assert room._id?, "Created room does not have an _id: #{room}"
        @rooms[room._id] = room
      else if type == 'update'
        Rooms.save_room room
      else if type == 'delete'
        Rooms.remove {_id: room._id}
      else
        assert false, "Invalid update type: #{type}"
