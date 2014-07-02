class @Model
  constructor: (@rooms, @room_names) ->
    Rooms.remove {}
    Chats.remove {}
    @_updates = []

  transaction: (callback) ->
    result = Meteor._noYieldsAllowed callback
    do @_commit
    result

  create_room: (room) ->
    assert not room._id?, "Tried to create room with _id: #{room}"
    @_updates.push ['create', room]

  update_room: (room) ->
    assert room._id?, "Tried to save room without _id: #{room}"
    @_updates.push ['update', room]

  delete_room: (room) ->
    assert room._id of @rooms, "Missing room_id: #{room}"
    assert room.users.length == 0, "Tried to delete non-empty room: #{room}"
    delete @rooms[room._id]
    @room_names.free_name room.name
    @_updates.push ['delete', room]

  _commit: ->
    for [type, room] in @_updates
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
    @_updates.length = 0
