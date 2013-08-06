Meteor.publish('rooms', ->
  lobby_cursor = Rooms.find(name: Rooms.lobby_name)
  user = Users.findOne(_id: @userId)
  if not user?.fields?.room_ids
    if user
      Users.update({_id: @userId},
        $set: 'fields.room_ids': [Rooms.get_lobby()._id],
      )
    return lobby_cursor
  Rooms.find(_id: $in: user.fields.room_ids)
)

Meteor.publish('users', ->
  fields = username: true, fields: true
  Users.find({'fields.active': true}, fields: fields)
)


Meteor.methods({
  'heartbeat': ->
    Users.heartbeat(@userId)
})


Meteor.setInterval((() ->
  Users.mark_idle_users(Common.idle_timeout)
), Common.idle_timeout)
