Template.menu_box.disable_create_game = ->
  if (do Session.get_wait_id)? then 'disabled' else ''

Template.menu_box.events
  'click .btn.create-game': (e) ->
    do CreateGameModal.show

  'click .btn.leave-game': (e) ->
    LeaveGameModal.show do Session.get_room_id
