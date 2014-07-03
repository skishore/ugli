Meteor.startup ->
  Deps.autorun ->
    if (do Meteor.userId)?
      Meteor.subscribe 'current_room'
      room_id = do Session.get_room_id
      if room_id?
        Meteor.subscribe 'chats', room_id
      if do Session.get_in_lobby
        Meteor.subscribe 'game_rooms'

  Deps.autorun ->
    rooms = do (Rooms.find {players: Meteor.user()?.username}).fetch

    room_id = null
    in_lobby = true
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
