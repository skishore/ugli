Template.menu_box.disable_create_game = ->
  if (do Session.get_wait_id)? then 'disabled' else ''

Template.menu_box.events
  'click .btn.create-game': (e) ->
    $('#create-game-modal').modal 'show'

  'click .btn.leave-game': (e) ->
    Meteor.call 'leave_game', do Session.get_room_id
