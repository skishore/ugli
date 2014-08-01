Meteor.startup ->
  Deps.autorun ->
    if (do Meteor.userId)?
      Meteor.subscribe 'current_room'
      Meteor.subscribe 'chats', do Session.get_game_id
      if not do Session.get_in_game
        Meteor.subscribe 'game_rooms'

  Deps.autorun ->
    rooms = do (Rooms.find {players: Meteor.user()?.username}).fetch

    lobby_id = null
    game_id = null
    in_game = false
    in_multiplayer_game = false

    for room in rooms
      if room.state == RoomState.LOBBY
        lobby_id = room._id
      else
        game_id = room._id
        in_game = room.state == RoomState.PLAYING
        in_multiplayer_game = in_game and room.multiplayer

    Session.set_lobby_id lobby_id
    Session.set_game_id game_id
    Session.set_in_game in_game
    Session.set_in_multiplayer_game in_multiplayer_game
