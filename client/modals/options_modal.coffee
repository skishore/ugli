class @OptionsModal
  @show: ->
    if Common.ugli_options?
      elt = $('<div>')
      options = Meteor.user()?.profile?.options
      @options_binding = (do Common.ugli_options).make_options_ui elt, options
      BaseModal.show @, 'Options', elt, [
        {class: 'btn-default', text: 'Cancel', action: false}
        {class: 'btn-primary', text: 'Ok', action: true}
      ]
    else
      elt = $('<div>').text 'There are no options for this game. Sorry!'
      BaseModal.show @, 'Options', elt, [
        {class: 'btn-primary', text: 'Ok', action: false}
      ]

  @hide: (set_options) ->
    if set_options
      options = do @options_binding
      try
        (do Common.ugli_options).validate_options options
      catch err
        console.log err
        return
      Meteor.users.update {_id: do Meteor.userId},
          $set: 'profile.options': options
