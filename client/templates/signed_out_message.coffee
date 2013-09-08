Template.signed_out_message.rendered = ->
  Session.set 'Meteor.loginButtons.dropdownVisible', true
  # HACK: Defer the focus event to after the dropdown is shown. Racy.
  Meteor.setTimeout (-> $('#login-username-or-email').focus()), 100
