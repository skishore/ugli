Template.player_list.players = ->
  (Rooms.findOne {_id: Session.get 'room_id'}, {players: 1})?.players or []

Template.player_list.num_players = ->
  (do Template.player_list.players).length

Template.player_list.player_str = ->
  count = do Template.player_list.num_players
  if count == 1 then 'person' else 'people'
