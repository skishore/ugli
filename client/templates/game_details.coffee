active_if = (condition) ->
  if condition then '' else 'disabled'


Template.game_details.game = ->
  room_id = (do Session.get_game_id) or (do Session.get_game_details_id)
  game = Rooms.findOne {_id: room_id}

  if game?
    num_empty_spots = Math.max game.summary.max_players - game.players.length, 0
    game.empty_spots = [0...num_empty_spots]

    username = Meteor.user()?.username
    game.disable_start_game = active_if game.summary.host == username
    game.disable_join_game = active_if game.summary.open
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
    LeaveGameModal.show @_id

  'click .btn.start-game': (e) ->
    Meteor.call 'start_game', @_id
