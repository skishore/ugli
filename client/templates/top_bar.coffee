Template.top_bar.room_name = ->
  (Rooms.findOne {_id: do Session.get_room_id}, {name: 1})?.name or ''
