Meteor.startup ->
  Deps.autorun ->
    if Meteor.userId()? or Session.get 'room_id'
      Meteor.subscribe 'data'

  Deps.autorun ->
    Session.set 'room_id', (Rooms.findOne {}, {_id: 1})?._id

  Meteor.setInterval (->
    if Meteor.userId()?
      Meteor.call 'heartbeat', (err, result) ->
        console.log err if err?
  ), 1000
