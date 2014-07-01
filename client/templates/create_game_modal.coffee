Template.create_game_modal.events
  'click .btn.cancel': (e) ->
    $('#create-game-modal').modal 'hide'

  'click .btn.ok': (e) ->
    $('#create-game-modal').modal 'hide'


#Meteor.startup ->
  #config_elt = $('#create-game-modal').find '.modal-body'
  #(do Common.ugli_client).create_config_ui config_elt
