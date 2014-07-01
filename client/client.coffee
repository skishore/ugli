Meteor.startup ->
  Deps.autorun ->
    if Meteor.userId()?
      Meteor.subscribe 'current_room'

  Deps.autorun ->
    room = Rooms.findOne {user_ids: Meteor.userId() or null}
    if room?
      Session.set_room_id room._id
      Session.set_in_lobby room.state == RoomState.LOBBY
    else
      Session.set_room_id null
      Session.set_in_lobby false

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
