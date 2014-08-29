Template.signed_out_message.show_guest_account = ->
  (not Session.get 'Meteor.loginButtons.inSignupFlow') and
  (not Session.get 'Meteor.loginButtons.inForgotPasswordFlow')

Template.signed_out_message.rendered = ->
  Session.set 'Meteor.loginButtons.dropdownVisible', true

Template.signed_out_message.events
  'click .guest-account-message .btn': ->
    username = GUEST_NAMES[Math.floor GUEST_NAMES.length*do Math.random]
    Accounts.createUser {
      password: Meteor.uuid()
      username: username
      profile: guest: true
    }, (err) ->
      return console.log if err
      Session.set 'Meteor.loginButtons.dropdownVisible', false
