ask_about_autoremove = ->
  $('<div>').append \
    ($('<p>').text 'You are the last person to leave this game.'),
    ($('<p>').text 'Do you want to delete it as well?')


ask_about_forfeit = ->
  $('<div>').append \
    ($('<p>').text 'Leaving now may forfeit the current game.'),
    ($('<p>').text 'Do you still want to leave?')


class @LeaveGameModal
  @show: (@room_id) ->
    room = Rooms.get @room_id
    if not room?
      return
    if room.multiplayer and room.summary?.would_forfeit
      autoremove = !!Common.autoremove
      BaseModal.show @, 'Leave game', (do ask_about_forfeit), [
        {class: 'btn-default', text: 'Yes', action: {autoremove: true}}
        {class: 'btn-primary', text: 'No', action: false}
      ]
    else if room.players.length == 1
      if not room.multiplayer or Common.autoremove?
        Meteor.call 'leave_game', @room_id
      else
        BaseModal.show @, 'Leave game', (do ask_about_autoremove), [
          {class: 'btn-default', text: 'Yes', action: {autoremove: true}}
          {class: 'btn-default', text: 'No', action: {autoremove: false}}
        ]
    else
      Meteor.call 'leave_game', @room_id

  @hide: (leave) ->
    if leave
      Meteor.call 'leave_game', @room_id, leave.autoremove
    true
