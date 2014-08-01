Template.menu_box.disable_create_game = ->
  if (do Session.get_game_id)? then 'disabled' else ''

Template.menu_box.disable_play_singleplayer = ->
  hide = (do Session.get_in_game) and not (do Session.get_in_multiplayer_game)
  if hide then 'disabled' else ''

Template.menu_box.show_singleplayer = ->
  Common.singleplayer_config?

Template.menu_box.events
  'click .btn.create-game': (e) ->
    do CreateGameModal.show

  'click .btn.leave-game': (e) ->
    LeaveGameModal.show do Session.get_game_id

  'click .btn.play-singleplayer': (e) ->
    do PlaySingleplayerModal.show
