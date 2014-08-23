Template.signed_out_message.rendered = ->
  Session.set 'Meteor.loginButtons.dropdownVisible', true

Template.signed_out_message.events
  'click .guest-account-message .btn': ->
    username = "guest#{('' + Math.random()).slice(2, 8)}"
    Accounts.createUser {
      password: Meteor.uuid()
      username: username
      profile: guest: true
    }, (err) ->
      return console.log if err
      Session.set 'Meteor.loginButtons.dropdownVisible', false
