Template.player_list.num_players = ->
  do Users.find().count

Template.player_list.player_str = ->
  if Users.find().count() == 1 then 'person' else 'people'

Template.player_list.players = ->
  Users.find {}, sort: username: 1
