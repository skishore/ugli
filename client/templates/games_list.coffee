Template.games_list.games = ->
  Rooms.find(is_game: true)

Template.games_list.is_member = ->
  Meteor.userId() in @user_ids

Template.games_list.disabled = ->
  game_state = GameStates.get_current_state @_id
  # TODO(skishore): Show some information about why the game is closed here.
  if game_state?.public_view?.open then '' else 'disabled'

Template.games_list.events
  'click .join-button': (e) ->
    room_id = $(e.target).data 'room-id'
    Meteor.call 'join_game', room_id, (err, result) ->
      console.log err if err

  'click .leave-button': (e) ->
    room_id = $(e.target).data 'room-id'
    Meteor.call 'leave_game', room_id, (err, result) ->
      console.log err if err
