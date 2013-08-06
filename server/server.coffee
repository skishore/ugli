Meteor.methods({
  'create_player': () ->
    Players.create_player()

  'heartbeat': (player_id) ->
    Players.heartbeat(player_id)
})


Meteor.setInterval((() ->
  Players.remove_old_players()
), Common.remove_timeout)
