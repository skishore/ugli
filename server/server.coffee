Meteor.publish('users', ->
  Users.publish @userId
)
Meteor.publish('rooms', ->
  Rooms.publish @userId
)
Meteor.publish('chats', (room_ids) ->
  Chats.publish @userId, room_ids
)


Meteor.methods({
  'heartbeat': ->
    Users.heartbeat @userId

  'send_chat': (room_id, message) ->
    Chats.send_chat @userId, room_id, message
})


Meteor.setInterval((() ->
  Users.mark_users_idle(Common.idle_timeout)
), Common.idle_timeout)
