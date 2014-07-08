Template.top_bar.room_name = ->
  game = Rooms.findOne {_id: do Session.get_game_id}, {name: 1}
  game?.name or Common.lobby_name
