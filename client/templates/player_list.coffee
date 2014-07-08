get_players = (room_id) ->
  (Rooms.findOne {_id: room_id}, {players: 1})?.players or []

pluralize = (count) ->
  if count == 1 then 'person' else 'people'


Template.player_list.game_header = ->
  players = do Template.player_list.game_players
  "#{players.length} #{pluralize players.length} in-game"

Template.player_list.game_players = ->
  get_players do Session.get_game_id

Template.player_list.lobby_header = ->
  players = do Template.player_list.lobby_players
  "#{players.length} #{pluralize players.length} in the lobby"

Template.player_list.lobby_players = ->
  get_players do Session.get_lobby_id
