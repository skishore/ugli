Template.player_list.num_players = ->
  (Rooms.findOne {}, {players: 1})?.players.length or 0

Template.player_list.player_str = ->
  count = do Template.player_list.num_players
  if count == 1 then 'person' else 'people'

Template.player_list.players = ->
  players = (Rooms.findOne {}, {players: 1})?.players
  if players then do players.sort else []
