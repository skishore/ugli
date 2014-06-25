Accounts.ui.config {
  passwordSignupFields: 'USERNAME_AND_OPTIONAL_EMAIL',
}


Meteor.startup ->
  Deps.autorun ->
    if Meteor.userId()?
      Meteor.subscribe 'users'

  Meteor.setInterval (->
    if Meteor.userId()?
      Meteor.call 'heartbeat', (err, result) ->
        console.log err if err?
  ), 1000
