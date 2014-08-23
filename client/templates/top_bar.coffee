Template.top_bar.guest = ->
  if (do Meteor.user)?.profile?.guest then 'guest-nav' else undefined

Template.top_bar.room_name = ->
  if do Session.get_in_game
    (Rooms.findOne {_id: do Session.get_game_id}, {name: 1})?.name
  else
    (Rooms.findOne {_id: do Session.get_lobby_id}, {name: 1})?.name
