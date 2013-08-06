# name: string
@Rooms = new Collection('rooms', ['name'], 'name')

@using @Rooms, ->
  @get_initial_room_ids = ->
    rooms = @find().fetch()
    room_ids = []
    while not room_ids.length
      for room in rooms
        if Math.random() > 0.5
          room_ids.push room._id
    room_ids
