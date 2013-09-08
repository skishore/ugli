Template.user_list.num_users = ->
  room = Rooms.get Session.get 'room_id'
  Users.find(_id: $in: (room?.user_ids or [])).count()

Template.user_list.users = ->
  room = Rooms.get Session.get 'room_id'
  Users.find({_id: $in: (room?.user_ids or [])}, sort: username: 1)
