class @FeedbackModal
  @show: ->
    @feedback_elt = $('<div>')
    UI.insert (UI.render Template.feedback_modal), @feedback_elt[0]
    # Fill in the user's email, if it is available.
    user = do Meteor.user
    if user?.emails?.length > 0
      @feedback_elt.find('.form-control.email').val user.emails[0].address

    BaseModal.show @, 'Send feedback', @feedback_elt, [
      {class: 'btn-default', text: 'Cancel', action: false}
      {class: 'btn-primary', text: 'Send', action: true}
    ]

  @hide: (send) ->
    if send
      options = {}
      validated = true
      for field in ['email', 'subject', 'text']
        element = @feedback_elt.find ".form-control.#{field}"
        value = do element.val
        if value?.length > 0
          element.parent().removeClass 'has-error'
          options[field] = value
        else
          element.parent().addClass 'has-error'
          validated = false
      if not validated
        return false
      Meteor.call 'send_feedback_email', options
    delete @feedback_elt
    true
