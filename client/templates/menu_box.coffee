Template.menu_box.disable_create_game = ->
  if (do Session.get_game_id)? then 'disabled' else ''

Template.menu_box.events
  'click .btn.create-game': (e) ->
    do CreateGameModal.show

  'click .btn.leave-game': (e) ->
    LeaveGameModal.show do Session.get_game_id
