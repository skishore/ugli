Meteor.publish('users', -> Users.publish @userId)
Meteor.publish('rooms', -> Rooms.publish @userId)
Meteor.publish('chats', -> Chats.publish @userId)


Meteor.methods({
  'heartbeat': ->
    Users.heartbeat @userId

  'send_chat': (room_id, message) ->
    Chats.send_chat @userId, room_id, message
})


Meteor.setInterval((() ->
  Users.mark_idle_users(Common.idle_timeout)
), Common.idle_timeout)
