Meteor.publish('rooms', (player_id) ->
  player = Players.findOne(_id: player_id)
  Rooms.find(_id: $in: player.room_ids)
)

Meteor.publish('players', ->
  Players.find({}, fields: _id: 0)
)

Meteor.publish('my_player', (player_id) ->
  Players.find({_id: player_id}, fields: _id: 0)
)


Meteor.methods({
  'create_player': () ->
    Players.create_player()

  'heartbeat': (player_id) ->
    Players.heartbeat(player_id)
})


Meteor.setInterval((() ->
  Players.remove_old_players()
), Common.remove_timeout)
