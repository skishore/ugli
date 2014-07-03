class @LeaveGameModal
  @show: (@room_id) ->
    room = Rooms.findOne {_id: @room_id}
    if room?.players.length == 1
      $('#leave-game-modal').modal 'show'
    else
      Meteor.call 'leave_game', @room_id

  @hide: (autoremove) ->
    $('#leave-game-modal').modal 'hide'
    Meteor.call 'leave_game', @room_id, autoremove


Template.leave_game_modal.events
  'click .btn.yes': (e) ->
    LeaveGameModal.hide true

  'click .btn.no': (e) ->
    do LeaveGameModal.hide
