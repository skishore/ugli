Template.game_info.show_game_details = ->
  (do Session.get_wait_id)? or (do Session.get_game_details_id)?

Meteor.startup ->
  Deps.autorun ->
    if do Session.get_in_lobby
      Session.set_game_details_id null
