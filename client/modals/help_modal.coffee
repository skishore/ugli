class @HelpModal
  @show: ->
    config_elt = $('<div>')
    (do Common.ugli_client).make_help_ui config_elt
    BaseModal.show @, 'Help', config_elt, [
      {class: 'btn-default', text: 'Ok', action: true}
    ]

  @hide: (action) ->
