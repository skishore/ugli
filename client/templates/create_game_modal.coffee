class @CreateGameModal
  @show: ->
    config_elt = $('#create-game-modal').find '.modal-body'
    do config_elt.empty
    @config_binding = (do Common.ugli_client).make_config_ui config_elt
    $('#create-game-modal').modal 'show'

  @hide: (create_game) ->
    $('#create-game-modal').modal 'hide'
    if create_game
      Meteor.call 'create_game', do @config_binding


Template.create_game_modal.events
  'click .btn.cancel': (e) ->
    CreateGameModal.hide false

  'click .btn.ok': (e) ->
    CreateGameModal.hide true
