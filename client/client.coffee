Meteor.startup ->
  Deps.autorun ->
    if Meteor.userId()?
      Meteor.subscribe 'rooms'

  Deps.autorun ->
    Session.set 'room_id', (Rooms.findOne {}, {_id: 1})?._id

  Deps.autorun ->
    room_id = Session.get 'room_id'
    if room_id?
      Meteor.subscribe 'chats', room_id

  Meteor.setInterval (->
    if Meteor.userId()?
      Meteor.call 'heartbeat', (err, result) ->
        console.log err if err?
  ), 1000
