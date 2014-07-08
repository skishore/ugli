Template.game_info.show_game_details = ->
  waiting = (do Session.get_game_id)? and not (do Session.get_in_game)
  waiting or (do Session.get_game_details_id)?


Meteor.startup ->
  Deps.autorun ->
    if not do Session.get_in_game
      Session.set_game_details_id null
