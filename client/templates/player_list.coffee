players = (room_id) ->
  (Rooms.findOne {_id: room_id}, {players: 1})?.players or []

pluralize = (count) ->
  if count == 1 then 'person' else 'people'


Template.player_list.game_players = ->
  result = players do Session.get_game_id
  result.unshift "#{result.length} #{pluralize result.length} in-game"
  result

Template.player_list.lobby_players = ->
  result = players do Session.get_lobby_id
  result.unshift "#{result.length} #{pluralize result.length} in the lobby"
  result
