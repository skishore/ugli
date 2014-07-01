config_binding = null


Template.create_game_modal.events
  'click .btn.cancel': (e) ->
    $('#create-game-modal').modal 'hide'

  'click .btn.ok': (e) ->
    $('#create-game-modal').modal 'hide'
    console.log do config_binding


Meteor.startup ->
  config_elt = $('#create-game-modal').find '.modal-body'
  config_binding = (do Common.ugli_client).make_config_ui config_elt
