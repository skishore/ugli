class @CreateGameModal
  @show: ->
    config_elt = $('<div>')
    @config_binding = (do Common.ugli_client).make_config_ui config_elt
    BaseModal.show @, 'Create game', config_elt, [
      {class: 'btn-default', text: 'Cancel', action: false}
      {class: 'btn-primary', text: 'Ok', action: true}
    ]

  @hide: (create_game) ->
    if create_game
      Meteor.call 'create_game', do @config_binding
    delete @config_binding
    true
