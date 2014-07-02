Template.game_details.game = ->
  wait_id = do Session.get_wait_id
  if wait_id?
    game = Rooms.findOne {_id: wait_id}
  else
    game = Rooms.findOne {_id: do Session.get_game_details_id}

  if game?
    num_empty_spots = Math.max game.summary.max_players - game.players.length, 0
    game.empty_spots = [0...num_empty_spots]
    username = Meteor.user()?.username
    game.is_host = (game.summary.host == username)
    game.is_member = (game.players.indexOf username) >= 0
  else
    Session.set_game_details_id null
  game

Template.game_details.events
  'click .btn.back-to-list': (e) ->
    Session.set_game_details_id null

  'click .btn.join-game': (e) ->
    Meteor.call 'join_game', @_id

  'click .btn.leave-game': (e) ->
    Session.set_game_details_id null
    Meteor.call 'leave_game', @_id

  'click .btn.start-game': (e) ->
    Meteor.call 'start_game', @_id
