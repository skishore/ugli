Template.game_details.game = ->
  game = Rooms.findOne {_id: do Session.get_game_details_id}
  if game?
    num_empty_spots = game.summary.max_players - game.players.length
    game.empty_spots = (1 for x in [0...num_empty_spots])
  else
    Session.set_game_details_id null
  game

Template.game_details.events
  'click .btn.back-to-list': (e) ->
    Session.set_game_details_id null
