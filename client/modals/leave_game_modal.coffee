create_body = ->
  $('<div>').append \
    ($('<p>').text 'You are the last person to leave this game.'),
    ($('<p>').text 'Do you want to delete it as well?')


class @LeaveGameModal
  @show: (@room_id) ->
    room = Rooms.get @room_id
    if room?.players.length == 1
      if not room.multiplayer
        autoremove = not Common.persist_singleplayer_rooms
        Meteor.call 'leave_game', @room_id, autoremove
      else if Common.autoremove?
        Meteor.call 'leave_game', @room_id, Common.autoremove
      else
        BaseModal.show @, 'Leave game', (do create_body), [
          {class: 'btn-default', text: 'Yes', action: true}
          {class: 'btn-default', text: 'No', action: false}
        ]
    else
      Meteor.call 'leave_game', @room_id

  @hide: (autoremove) ->
    Meteor.call 'leave_game', @room_id, autoremove
    true
