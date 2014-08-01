create_body = ->
  $('<div>').append \
    ($('<p>').text 'You will have to leave the current game to play singleplayer.'),
    ($('<p>').text 'Do you want to proceed?')


class @PlaySingleplayerModal
  @show: ->
    if (do Session.get_game_id)?
      BaseModal.show @, 'Play singleplayer', (do create_body), [
        {class: 'btn-default', text: 'Yes', action: true}
        {class: 'btn-primary', text: 'No', action: false}
      ]
    else
      Meteor.call 'create_singleplayer_game'


  @hide: (leave_game) ->
    if leave_game
      Meteor.call 'create_singleplayer_game'
