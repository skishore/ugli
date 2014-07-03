old_subscribe = Meteor.subscribe
Meteor.subscribe = (x, y, z, w) ->
  console.log x, y, z, w
  old_subscribe x, y, z, w

Meteor.startup ->
  Deps.autorun ->
    if Meteor.userId()?
      Meteor.subscribe 'current_room'

  Deps.autorun ->
    rooms = do (Rooms.find {players: Meteor.user()?.username}).fetch

    room_id = null
    in_lobby = false
    wait_id = null

    for room in rooms
      if room.state == RoomState.WAITING
        wait_id = room._id
      else
        room_id = room._id
        in_lobby = room.state == RoomState.LOBBY

    Session.set_room_id room_id
    Session.set_in_lobby in_lobby
    Session.set_wait_id wait_id

  Deps.autorun ->
    room_id = do Session.get_room_id
    if room_id?
      Meteor.subscribe 'chats', room_id
    if do Session.get_in_lobby
      Meteor.subscribe 'game_rooms'

  Meteor.setInterval (->
    if Meteor.userId()?
      Meteor.call 'heartbeat', (err, result) ->
        console.log err if err?
  ), 1000
